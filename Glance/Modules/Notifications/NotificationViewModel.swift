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
        let selection : Observable<NotificationCellViewModel>

    }

    struct Output {
        let items : Driver<[NotificationCellViewModel]>

    }
    
    let element : BehaviorRelay<PageMapable<Notification>?> = BehaviorRelay(value: nil)

    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[NotificationCellViewModel]>(value: [])
                
        
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

        element.filterNil().map { items -> [NotificationCellViewModel] in
            return items.list.map { item -> NotificationCellViewModel  in
                let viewModel = NotificationCellViewModel(item: item)
                return viewModel
            }
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
