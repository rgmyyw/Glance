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
//        let saved : Driver<Void>
    }
    
    let element : BehaviorRelay<PageMapable<Notification>> = BehaviorRelay(value: PageMapable<Notification>())

    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[NotificationCellViewModel]>(value: [])
                
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Notification>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
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
                    
                self.hasData.onNext(item.hasNext)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Notification>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                return Observable.just(RxSwift.Event.completed)
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
                temp.list = self.element.value.list + item.list
                self.element.accept(temp)
                self.hasData.onNext(item.hasNext)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        element.map { items -> [NotificationCellViewModel] in
            return items.list.map { item -> NotificationCellViewModel  in
                let viewModel = NotificationCellViewModel(item: item)
                return viewModel
            }
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
//        let items = (0...20).map { (_) -> NotificationCellViewModel  in
//            let viewModel = NotificationCellViewModel(item: Notification())
//            return viewModel
//        }
//
//        elements.accept(items)

        
//        input.selection.subscribe(onNext: { item in
//            elements.value.forEach { (i) in i.selected.accept(false) }
//            item.selected.accept(true)
//            saved.onNext(())
//        }).disposed(by: rx.disposeBag)
                
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
