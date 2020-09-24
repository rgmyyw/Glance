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

class ShoppingCartViewModel: ViewModel, ViewModelType {
        
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<ShoppingCartCellViewModel>

    }

    struct Output {
        let items : Driver<[ShoppingCartCellViewModel]>
        let delete : Observable<ShoppingCartCellViewModel>
        let comparePrice : Driver<String>
        let openURL : Driver<URL>
        let detail :  Driver<Home>
    }
    
    let element : BehaviorRelay<PageMapable<ShoppingCart>> = BehaviorRelay(value: PageMapable<ShoppingCart>())
    let confirmDelete = PublishSubject<ShoppingCartCellViewModel>()
    let selectStoreActions = PublishSubject<(action : SelectStoreAction, item : SelectStore)>()


    func transform(input: Input) -> Output {
        ShoppingCart
        let elements = BehaviorRelay<[ShoppingCartCellViewModel]>(value: [])
        let delete = PublishSubject<ShoppingCartCellViewModel>()
        let comparePrice = PublishSubject<String>()
        let buy = PublishSubject<ShoppingCartCellViewModel>()
        let openURL = PublishSubject<URL>()
        let detail = PublishSubject<Home>()
        
        
        
        input.selection.map { Home(productId: $0.item.productId ?? "")}
            .bind(to: detail).disposed(by: rx.disposeBag)
        buy.map { $0.item.productUrl?.url}.filterNil()
            .bind(to: openURL).disposed(by: rx.disposeBag)
        selectStoreActions.filter { $0.action == .buy }
            .map { $0.item.productUrl?.url }.filterNil()
            .bind(to: openURL).disposed(by: rx.disposeBag)
        
        selectStoreActions.filter { $0.action == .jump }
            .map { Home(productId: $0.item.productId ?? "")}
            .delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: detail).disposed(by: rx.disposeBag)
        

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
                viewModel.delete.map { viewModel}.bind(to: delete).disposed(by: self.rx.disposeBag)
                viewModel.comparePrice.map { viewModel.item.productId }.filterNil().bind(to: comparePrice).disposed(by: self.rx.disposeBag)
                viewModel.buy.map { viewModel}.bind(to: buy).disposed(by: self.rx.disposeBag)

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
            }).subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let (cellViewModel, result)):
                    var items = elements.value
                    items.removeFirst(where: { $0.item == cellViewModel.item})
                    elements.accept(items)
                    self?.message.onNext(.init("Product has been removed"))
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

                
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      delete: delete.asObservable(),
                      comparePrice: comparePrice.asDriverOnErrorJustComplete(),
                      openURL: openURL.asDriverOnErrorJustComplete(),
                      detail: detail.asDriverOnErrorJustComplete())
    }
}
