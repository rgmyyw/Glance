//
//  StyleBoardSearchViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class StyleBoardSearchViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let footerRefresh: Observable<Void>
        let selection : Observable<StyleBoardSearchSectionItem>
        let add : Observable<Void>
        let currentType : BehaviorRelay<ProductSearchType>
        
    }
    
    struct Output {
        let items : Driver<[StyleBoardSearchSection]>
        let placeholder : Driver<String>
        let addButtonEnable : Driver<Bool>
    }
    
    
    let textInput = BehaviorRelay<String>(value: "")
    let element : BehaviorRelay<PageMapable<DefaultColltionItem>?> = BehaviorRelay(value: nil)
    let selection = PublishSubject<[DefaultColltionItem]>()
    
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[StyleBoardSearchSection]>(value: [])
        let placeholder = input.currentType.map { $0.placeholder }.asDriver(onErrorJustReturn: "")
        let addButtonEnable = BehaviorRelay<Bool>(value: false)
                
        input.currentType.mapToVoid()
            .subscribe(onNext: {[weak self]() in
                self?.element.accept(nil)
                elements.accept([])
        }).disposed(by: rx.disposeBag)
        
        input.add.flatMapLatest { () -> Observable<[DefaultColltionItem]> in
            let elements = elements.value.flatMap { $0.items.filter { $0.viewModel.selected.value } }
            let items = elements.map { $0.viewModel.item }
            return Observable.just(items)
        }.bind(to: selection).disposed(by: rx.disposeBag)
        
        input.selection.subscribe(onNext: { item in
            item.viewModel.selected.accept(!item.viewModel.selected.value)
            let items =  elements.value.flatMap { $0.items.map { $0.viewModel } }.filter { $0.selected.value }
            addButtonEnable.accept(!items.isEmpty)
        }).disposed(by: rx.disposeBag)
        
        
        textInput.filterEmpty()
            .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .flatMapLatest({ [weak self] (text) -> Observable<(RxSwift.Event<PageMapable<DefaultColltionItem>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                elements.accept([])
                self.page = 1
                return self.provider.productSearch(type: input.currentType.value,keywords: text, page: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    self.noMoreData.onNext(())
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<DefaultColltionItem>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !(self.element.value?.hasNext ?? false) {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            let text = self.textInput.value
            return self.provider.productSearch(type: input.currentType.value,keywords: text, page: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = (self.element.value?.list ?? [] ) + item.list
                self.element.accept(temp)
                self.noMoreData.onNext(())
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.filterNil().map { element -> [StyleBoardSearchSection] in
            if element.list.isEmpty { return [] }
            let sectionItems = element.list.enumerated().map { (indexPath, item) -> StyleBoardSearchSectionItem in
                let cellViewModel = StyleBoardSearchCellViewModel(item: item)
                let sectionItem = StyleBoardSearchSectionItem(item: indexPath, viewModel: cellViewModel)
                return sectionItem
            }
            let section = StyleBoardSearchSection(section: 0, elements: sectionItems)
            return [section]
            
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      placeholder: placeholder,
                      addButtonEnable: addButtonEnable.asDriver(onErrorJustReturn: false))
    }
}
