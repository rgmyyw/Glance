//
//  NoticeViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NoticeViewModel: ViewModel, ViewModelType {

    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection: Observable<NoticeSectionItem>
        let clear: Observable<Void>
    }

    struct Output {
        let items: Driver<[NoticeSection]>
        let userDetail: Driver<User>
        let themeDetail: Driver<Int>
        let postDetail: Driver<DefaultColltionItem>
        let insightDetail: Driver<Insight>
    }

    let element: BehaviorRelay<PageMapable<Notice>?> = BehaviorRelay(value: nil)

    func transform(input: Input) -> Output {

        let elements = BehaviorRelay<[NoticeSection]>(value: [])
        let follow = PublishSubject<NoticeCellViewModel>()
        let delete = PublishSubject<NoticeCellViewModel>()

        let postDetail = PublishSubject<NoticeCellViewModel>()
        let userDetail = PublishSubject<NoticeCellViewModel>()
        let themeDetail = PublishSubject<NoticeCellViewModel>()
        let insightDetail = PublishSubject<NoticeCellViewModel>()

        Observable.merge(postDetail, userDetail, themeDetail, insightDetail)
            .filter { !$0.read.value }
            .flatMap({ (cellViewModel) -> Observable<(NoticeCellViewModel, Bool)> in
                let id = cellViewModel.item.noticeId
                return BadgeValueManager.shared.makeRead(type: .notice(id: id))
                    .map { (cellViewModel, $0)}
            }).subscribe(onNext: { (cellViewModel, result) in
                cellViewModel.read.accept(true)
            }).disposed(by: rx.disposeBag)

        input.clear.flatMap({ (cellViewModel) -> Observable<Bool> in
            return BadgeValueManager.shared.makeRead(type: .notice(id: 0))
        }).subscribe(onNext: { (result) in
            elements.value.first?.items.forEach { $0.viewModel.read.accept(true)}
        }).disposed(by: rx.disposeBag)

        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Notice>>)> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                self.page = 1
                return self.provider.notifications(pageNum: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    self.refreshState.onNext(item.refreshState)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error {
                    default:
                        self.refreshState.onNext(.end)
                        logError(error.debugDescription)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Notice>>> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            self.page += 1
            return self.provider.notifications(pageNum: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = (self.element.value?.list ?? []) + item.list
                self.element.accept(temp)
                self.refreshState.onNext(item.refreshState)
            case .error(let error):
                guard let error = error.asExceptionError else { return }
                switch error {
                default:
                    self.page -= 1
                    self.refreshState.onNext(.end)
                    logError(error.debugDescription)
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        follow.flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<(Bool, NoticeCellViewModel)>> in
            guard let self = self else { return Observable.just(.completed) }
            let isFollow = cellViewModel.following.value
            let userId = cellViewModel.item.user?.userId ?? ""
            let request = isFollow ? self.provider.undoFollow(userId: userId) : self.provider.follow(userId: userId)
            return request
                .trackActivity(self.loading)
                .trackError(self.error)
                .map { ($0, cellViewModel)}
                .materialize()
        }).subscribe(onNext: { (event) in
            switch event {
            case .next(let (result, cellViewModel)):
                cellViewModel.following.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        element.filterNil().map { items -> [NoticeSection] in
            return [NoticeSection.noti(items: items.list.map { item -> NoticeSectionItem  in
                let viewModel = NoticeCellViewModel(item: item)
                viewModel.follow.map { viewModel }.bind(to: follow).disposed(by: self.rx.disposeBag)
                viewModel.delete.map { viewModel }.bind(to: delete).disposed(by: self.rx.disposeBag)
                viewModel.themeDetail.map { viewModel}.bind(to: themeDetail).disposed(by: self.rx.disposeBag)
                viewModel.userDetail.map { viewModel }.bind(to: userDetail).disposed(by: self.rx.disposeBag)
                return viewModel.makeItemType()
            })]
        }.bind(to: elements).disposed(by: rx.disposeBag)

        delete.flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<(Bool, NoticeCellViewModel)>> in
            guard let self = self else { return Observable.just(.completed) }
            let request = self.provider.deleteNotice(noticeId: cellViewModel.item.noticeId)
            return request
                .trackActivity(self.loading)
                .trackError(self.error)
                .map { ($0, cellViewModel)}
                .materialize()
        }).subscribe(onNext: { (event) in
            switch event {
            case .next(let (result, cellViewModel)):
                if result {
                    let element = elements.value[0]
                    var items = element.items
                    let index = items.firstIndex { $0.viewModel.item == cellViewModel.item }
                    if let index = index {
                        items.remove(at: index)
                    }
                    elements.accept([NoticeSection.init(original: element, items: items)])
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        input.selection.subscribe(onNext: { [weak self]( item) in
            switch item {
            case .liked(let viewModel), .recommended(let viewModel):
                postDetail.onNext(viewModel)
            case .reacted(let viewModel):
                insightDetail.onNext(viewModel)
            case .system(let viewModel):
                self?.message.onNext(.init("tap system message...\n\(viewModel.item.title ?? "")"))
            case .theme(let viewModel):
                themeDetail.onNext(viewModel)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      userDetail: userDetail.map { $0.item.user }.filterNil().asDriverOnErrorJustComplete(),
                      themeDetail: themeDetail.map { $0.item.themeId }.asDriverOnErrorJustComplete(),
                      postDetail: postDetail.map { DefaultColltionItem(postId: $0.item.postId)}.asDriverOnErrorJustComplete(),
                      insightDetail: insightDetail.map { Insight(recommendId: $0.item.recommendId)}.asDriverOnErrorJustComplete())
    }
}
