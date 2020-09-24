//
//  SelectStoreViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum SelectStoreAction {
    case add
    case buy
    case jump
}

class SelectStoreViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<SelectStoreCellViewModel>
        
    }
    
    struct Output {
        let items : Driver<[SelectStoreCellViewModel]>
        let close : Driver<Void>
    }
    
    
    let productId : BehaviorRelay<String>
    let action = PublishSubject<(action : SelectStoreAction, item : SelectStore)>()
    
    init(provider: API, productId: String) {
        self.productId = BehaviorRelay(value:productId )
        super.init(provider: provider)
    }
    
    let element : BehaviorRelay<[SelectStore]> = BehaviorRelay(value: [])
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SelectStoreCellViewModel]>(value: [])
        let complete = PublishSubject<Void>()
        let addShoppingCart = PublishSubject<SelectStoreCellViewModel>()
        let buy = PublishSubject<SelectStoreCellViewModel>()
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<[SelectStore]>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                let productId = self.productId.value
                return self.provider.compareOffers(productId: productId)
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
            
        
        element.filterEmpty().map {[weak self] items -> [SelectStoreCellViewModel] in
            guard let self = self else { return []}
            let i = items.map { item -> SelectStoreCellViewModel  in
                let viewModel = SelectStoreCellViewModel(item: item)
                viewModel.buy.map { viewModel }.bind(to: buy).disposed(by: self.rx.disposeBag)
                viewModel.addShoppingCart.map { viewModel }.bind(to: addShoppingCart).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            i.first?.displaying.accept(true)
            return i
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        addShoppingCart.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(Bool,SelectStoreCellViewModel)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            let productId = cellViewModel.item.productId ?? ""
            return self.provider.addShoppingCart(productId: productId)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { ($0,cellViewModel)}
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let (result,cellViewModel)):
                if result {
                    self?.message.onNext(.init("Successfully added to your shopping list"))
                    self?.action.onNext((.add,cellViewModel.item))
                    cellViewModel.inShoppingList.accept(result)
                } else {
                    self?.message.onNext(.init("add shoppingCart fail"))
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
                
        input.selection.mapToVoid().bind(to: complete).disposed(by: rx.disposeBag)
        input.selection.map { (action:SelectStoreAction.jump ,item : $0.item) }.bind(to: action).disposed(by: rx.disposeBag)
        
        buy.map { (action:SelectStoreAction.buy ,item : $0.item)}.bind(to: action).disposed(by: rx.disposeBag)
        buy.mapToVoid().bind(to: complete).disposed(by: rx.disposeBag)
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      close: complete.delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).asDriver(onErrorJustReturn: ()))
    }
}
