//
//  InterestViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class InterestViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let selection : Observable<InterestCellViewModel>
        let next : Observable<Void>
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,InterestCellViewModel>]>
        let tabbar : Driver<Void>
    }
    
    let element : BehaviorRelay<[Interest]> = BehaviorRelay(value: [])
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,InterestCellViewModel>]>(value: [])
        let selection = PublishSubject<InterestCellViewModel>()
        let commit = PublishSubject<String>()
        let tabbar = PublishSubject<Void>()
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<[Interest]>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                return self.provider.interest(level: 1)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let items):
                    self.element.accept(items)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        element.map { items -> [SectionModel<Void,InterestCellViewModel>] in
            let sectionItems = items.map { item -> InterestCellViewModel  in
                let viewModel = InterestCellViewModel(item: item)
                viewModel.selection.map { viewModel }.bind(to: selection).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            let sections = [SectionModel<Void,InterestCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        input.selection.subscribe(onNext: { (cellViewModel) in
            cellViewModel.selected.accept(!cellViewModel.selected.value)
        }).disposed(by: rx.disposeBag)
        
        input.next.map { elements.value[0].items }
            .map {  items -> [InterestCellViewModel] in
                return items.filter { $0.selected.value }
        }.subscribe(onNext: { [weak self] items in
            guard items.count >= 3 else {
                self?.exceptionError.onNext(.general("Please choose at least three"))
                return
            }
            let ids = items.map { $0.item.interestId.string }.joined()
            commit.onNext(ids)
        }).disposed(by: rx.disposeBag)
        
        commit.flatMapLatest({ [weak self] (ids) -> Observable<(RxSwift.Event<Bool>)> in
            guard let self = self else {
                return Observable.just(RxSwift.Event.completed)
            }
            return self.provider.updateUserInterest(ids: ids)
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let result):
                if result {
                    tabbar.onNext(())
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []), tabbar: tabbar.asDriver(onErrorJustReturn: ()))
    }
}
