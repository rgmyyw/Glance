//
//  VisualSearchResultViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/30.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class VisualSearchResultViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<VisualSearchResultSectionItem>
        let search : Observable<Void>
    }
    
    struct Output {
        let items : Driver<[VisualSearchResultSection]>
        let search : Observable<UIImage>

    }
    
    private let image : BehaviorRelay<UIImage>
    
    
    let imageURI = BehaviorRelay<String?>(value: nil)
    let currentRect : BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    let bottomViewHidden : BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    let searchSelection = PublishSubject<Home>()
    
    
    let element : BehaviorRelay<(Bool,VisualSearchPageMapable)> = BehaviorRelay(value: (false,VisualSearchPageMapable()))
    
    let selectedItems = BehaviorRelay<[Home]>(value: [])
    
    init(provider: API, image : UIImage) {
        self.image = BehaviorRelay(value: image)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[VisualSearchResultSection]>(value: [])
        let selectedItems = BehaviorRelay<[VisualSearchResultSectionItem]>(value:[])
        let box = BehaviorRelay<[CGFloat]>(value: [])
        let search = input.search.map { self.image.value }
        
        
        selectedItems.map { $0.isEmpty }.bind(to: bottomViewHidden).disposed(by: rx.disposeBag)
        selectedItems.map { $0.map { $0.viewModel.item }}.bind(to: self.selectedItems).disposed(by: rx.disposeBag)
        
        currentRect.filter { $0 != .zero }
            .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { rect in
                var rect = rect
                let scale = UIScreen.main.scale
                rect.x = rect.x * scale * 2.0
                rect.y = rect.y * scale * 2.0
                rect.size.width = rect.width * scale * 2.0
                rect.size.height = rect.height * scale * 2.0
                box.accept([rect.x, rect.x + rect.width, rect.y, rect.y + rect.height])
            }).disposed(by: rx.disposeBag)
        
        box.filterEmpty()
            .flatMapLatest({ [weak self] (box) -> Observable<(RxSwift.Event<VisualSearchPageMapable>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                elements.accept([])
                self.page = 1
                var param = [String : Any]()
                param["page"] = self.page
                param["limit"] = 10
                param["imUri"] = self.imageURI.value ?? ""
                param["imUrl"] = ""
                param["box"] = box
                //imId ["imId"]
                return self.provider.visualSearch(params: param)
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept((true, item))
                    self.hasData.onNext(item.hasNext)
                    
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<VisualSearchPageMapable>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.1.hasNext {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            var param = [String : Any]()
            param["page"] = self.page
            param["limit"] = 10
            param["imUri"] = self.imageURI.value ?? ""
            param["imUrl"] = ""
            param["imId"] = self.element.value.1.imId ?? ""
            
            return self.provider.visualSearch(params: param)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = self.element.value.1.list + item.list
                self.element.accept((false,temp))
                self.hasData.onNext(item.hasNext)
                
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        element.map { (first,items) -> [VisualSearchResultSection] in
            
            if items.list.isEmpty { return []}
            
            let sectionItems = items.list.enumerated().map { (offset, item) -> VisualSearchResultSectionItem  in
                let viewModel = VisualSearchResultCellViewModel(item: item)
                let item = VisualSearchResultSectionItem(item: offset, viewModel: viewModel)
                return item
            }
            if first, let item = sectionItems.first {
                item.viewModel.selected.accept(true)
                self.bottomViewHidden.accept(false)
                selectedItems.accept([item])
            }
            selectedItems.value.forEach { selected in
                for current in sectionItems {
                    if selected.viewModel.item.productId == current.viewModel.item.productId {
                        current.viewModel.selected.accept(true)
                        break
                    }
                }
            }
            return [VisualSearchResultSection(section: 0, elements: sectionItems)]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        searchSelection.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .map { item -> VisualSearchResultSectionItem in
                let viewModel = VisualSearchResultCellViewModel(item: item)
                viewModel.selected.accept(true)
                return VisualSearchResultSectionItem(item: elements.value[0].items.count, viewModel: viewModel)
        }.map { item -> [VisualSearchResultSection] in
            selectedItems.accept(selectedItems.value + [item])
            let section = elements.value[0]
            var items =  section.items
            items.insert(item, at: 0)
            return [VisualSearchResultSection(original: section, items: items)]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        
        
        
        input.selection.subscribe(onNext: { selection in
            selection.viewModel.selected.accept(!selection.viewModel.selected.value)
            let selected = elements.value.map { $0.items }.flatMap { $0.filter { $0.viewModel.selected.value } }
            selectedItems.accept(selected)
        }).disposed(by: rx.disposeBag)
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []), search: search)
    }
}
