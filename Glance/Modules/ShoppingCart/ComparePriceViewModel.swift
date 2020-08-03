//
//  ComparePriceViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ComparePriceViewModel: ViewModel, ViewModelType {
        
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<ShoppingCartCellViewModel>
    }

    struct Output {
        let items : Driver<[ShoppingCartCellViewModel]>

    }
    //ComparePriceCellViewModel
    let element : BehaviorRelay<PageMapable<ShoppingCart>> = BehaviorRelay(value: PageMapable<ShoppingCart>())
    let confirmDelete = PublishSubject<ShoppingCartCellViewModel>()
    

    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[ShoppingCartCellViewModel]>(value: [])
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<ShoppingCart>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.shoppingCart(pageNum: self.page)
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
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<ShoppingCart>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.shoppingCart(pageNum: self.page)
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

        element.map { items -> [ShoppingCartCellViewModel] in
            return items.list.map { item -> ShoppingCartCellViewModel  in
                let viewModel = ShoppingCartCellViewModel(item: item)
                return viewModel
            }
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
            
        confirmDelete
            .flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(ShoppingCartCellViewModel, Bool)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.shoppingCartDelete(productId: cellViewModel.item.productId ?? "")
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .map { (cellViewModel,$0)}
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (cellViewModel, result)):
                    var items = elements.value
                    items.removeFirst(where: { $0.item == cellViewModel.item})
                    elements.accept(items)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        
//        input.selection.subscribe(onNext: { item in
//            elements.value.forEach { (i) in i.selected.accept(false) }
//            item.selected.accept(true)
//            saved.onNext(())
//        }).disposed(by: rx.disposeBag)
                
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
