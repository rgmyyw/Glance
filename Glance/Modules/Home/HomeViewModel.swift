//
//  HomeViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<HomeSectionItem>
        
    }
    
    struct Output {
        let items : Driver<[HomeSection]>
    }
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[HomeSection]>(value: [])
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.getHome(page: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    if !item.hasNext  {
                        self.noMoreData.onNext(())
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Home>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                self.noMoreData.onNext(())
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            return self.provider.getHome(page: self.page)
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
                if !item.hasNext  {
                    self.noMoreData.onNext(())
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        element.map { items -> [HomeSection] in
            let sectionItems = items.list.map { HomeSectionItem.recommendItem(viewModel: HomeCellViewModel(item: $0))}
            let sections = [HomeSection.recommend(items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
            
//
//        input.selection.subscribe(onNext: { item in
//            elements.value.forEach { (i) in i.selected.accept(false) }
//            item.selected.accept(true)
//            CurrencyManager.shared.setDefault(item.item)
//            saved.onNext(())
//        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
