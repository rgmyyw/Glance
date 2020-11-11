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


class NotificationViewModel: ViewModel, ViewModelType {
        
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<NotificationSectionItem>
        let clear : Observable<Void>
    }

    struct Output {
        let items : Driver<[NotificationSection]>
        
    }
    
    let element : BehaviorRelay<PageMapable<Notification>?> = BehaviorRelay(value: nil)

    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[NotificationSection]>(value: [])
        let follow = PublishSubject<NotificationCellViewModel>()
        let userDetail = PublishSubject<User>()
        let themeDetail = PublishSubject<SearchTheme>()
                
        
        input.clear.subscribe(onNext: { () in
            elements.value.first?.items.forEach { $0.viewModel.unread.accept(true)}
        }).disposed(by: rx.disposeBag)
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Notification>>)> in
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
                    switch error  {
                    default:
                        self.refreshState.onNext(.end)
                        logError(error.debugDescription)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Notification>>> in
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
                switch error  {
                default:
                    self.page -= 1
                    self.refreshState.onNext(.end)
                    logError(error.debugDescription)
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        follow.flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<(Bool, NotificationCellViewModel)>> in
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

    
        element.accept(PageMapable<Notification>.init(hasNext: false, items: (0..<20).map { _ in Notification()}))

        element.filterNil().map { items -> [NotificationSection] in
            return [NotificationSection.noti(items:items.list.map { item -> NotificationSectionItem  in
                let viewModel = NotificationCellViewModel(item: item)
                viewModel.follow.map { viewModel }.bind(to: follow).disposed(by: self.rx.disposeBag)
                return viewModel.makeItemType()
            })]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
