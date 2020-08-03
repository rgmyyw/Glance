//
//  VisualSearchProductViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class VisualSearchProductViewModel: ViewModel, ViewModelType {
    
    
    
    struct Input {
        let search: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<VisualSearchProductCellViewModel>
    }
    
    struct Output {
        let items : Driver<[VisualSearchProductSection]>
    }
    
    
    let textInput = BehaviorRelay<String>(value: "")
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[VisualSearchProductSection]>(value: [])
        let selectedCellViewModel = BehaviorRelay<[VisualSearchProductCellViewModel]>(value:[])
        
        input.search
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<Home>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                elements.accept([])
                self.page = 1
                let text = self.textInput.value
                return self.provider.searchProductInApp(keywords: text, page: self.page)
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
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<Home>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.hasNext {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            let text = self.textInput.value
            return self.provider.searchProductInApp(keywords: text, page: self.page)
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
        
        
        element.map { element -> [VisualSearchProductSection] in
            
            let sectionItems = element.list.enumerated().map { (indexPath, item) -> VisualSearchProductSectionItem in
                let cellViewModel = VisualSearchProductCellViewModel(item: item)
                let sectionItem = VisualSearchProductSectionItem(item: indexPath, viewModel: cellViewModel)
                return sectionItem
            }
            let section = VisualSearchProductSection(section: 0, elements: sectionItems)
            return [section]
            
        }.share(replay: 1).bind(to: elements).disposed(by: rx.disposeBag)
        
        
        
        input.selection.subscribe(onNext: { cellViewModel in
            cellViewModel.selected.accept(!cellViewModel.selected.value)
            ///let selected = elements.value.map { $0.items }.flatMap { $0.filter { $0.selected.value } }
            //            selectedCellViewModel.accept(selected)
            
        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
