//
//  BlockedListViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InsightsRelationViewModel: ViewModel, ViewModelType {

    struct Input {
        let selection: Observable<InsightsLikeCellViewModel>
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
    }

    struct Output {
        let items: Driver<[InsightsLikeCellViewModel]>
        let navigationTitle: Driver<String>
    }

    let item: BehaviorRelay<Insight>
    let type: BehaviorRelay<InsightsRelationType>

    init(provider: API, item: Insight, type: InsightsRelationType) {
        self.item = BehaviorRelay(value: item)
        self.type = BehaviorRelay(value: type)
        super.init(provider: provider)
    }

    let element: BehaviorRelay<PageMapable<User>?> = BehaviorRelay(value: nil)

    func transform(input: Input) -> Output {

        let navigationTitle = type.map { $0.navigationTitle }.asDriver(onErrorJustReturn: "")
        let elements: BehaviorRelay<[InsightsLikeCellViewModel]> = BehaviorRelay(value: [])
        let buttonTap = PublishSubject<InsightsLikeCellViewModel>()

        input.headerRefresh.flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<User>>)> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                self.page = 1
                let postId = self.item.value.postId ?? 0
                let request = self.type.value == .liked ? self.provider.insightsLiked(postId: postId, pageNum: self.page) : self.provider.insightsRecommend(postId: postId, pageNum: self.page)
                return request
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

        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<User>>> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            self.page += 1
            let postId = self.item.value.postId ?? 0
            let request = self.type.value == .liked ? self.provider.insightsLiked(postId: postId, pageNum: self.page) : self.provider.insightsRecommend(postId: postId, pageNum: self.page)
            return request
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                let items = self.element.value?.list ?? []
                temp.list = items + item.list
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

        buttonTap.flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<(InsightsLikeCellViewModel, Bool)>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let userId = cellViewModel.item.userId ?? ""
            let request = cellViewModel.isFollow.value ? self.provider.undoFollow(userId: userId) :
                self.provider.follow(userId: userId)
            return request.trackActivity(self.loading)
                    .trackError(self.error)
                    .map { (cellViewModel, $0)}
                    .materialize()
        }).subscribe(onNext: { (event) in
            switch event {
            case .next(let (cellViewModel, result)):
                cellViewModel.isFollow.accept(result)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        element.filterNil().map { $0.list.map { item -> InsightsLikeCellViewModel in
            let cellViewModel =  InsightsLikeCellViewModel(item: item)
                cellViewModel.buttonTap.map { cellViewModel}.bind(to: buttonTap).disposed(by: self.rx.disposeBag)
                return cellViewModel
            }}.bind(to: elements).disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      navigationTitle: navigationTitle)
    }
}
