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
        let selection : Observable<VisualSearchResultCellViewModel>
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,VisualSearchResultCellViewModel>]>
    }
    
    let imageURI = BehaviorRelay<String?>(value: nil)
    let currentRect : BehaviorRelay<CGRect> = BehaviorRelay<CGRect>(value: .zero)
    let bottomViewHidden : BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    
    let element : BehaviorRelay<(Bool,VisualSearchPageMapable)> = BehaviorRelay(value: (false,VisualSearchPageMapable()))
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,VisualSearchResultCellViewModel>]>(value: [])
        let selectedCellViewModel = BehaviorRelay<[VisualSearchResultCellViewModel]>(value:[])
        let box = BehaviorRelay<[CGFloat]>(value: [])
        selectedCellViewModel.map { $0.isEmpty }.bind(to: bottomViewHidden).disposed(by: rx.disposeBag)
        
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
                .trackActivity(self.headerLoading)
                .materialize()
        }).subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                self.element.accept((true, item))
                if !item.hasNext  {
                    self.noMoreData.onNext(())
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<VisualSearchPageMapable>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !self.element.value.1.hasNext {
                self.noMoreData.onNext(())
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
                if !item.hasNext  {
                    self.noMoreData.onNext(())
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        element.map { (first,items) -> [SectionModel<Void,VisualSearchResultCellViewModel>] in
            let sectionItems = items.list.map { item -> VisualSearchResultCellViewModel  in
                let viewModel = VisualSearchResultCellViewModel(item: item)
                return viewModel
            }
            if first, let item = sectionItems.first {
                item.selected.accept(true)
                self.bottomViewHidden.accept(false)
                selectedCellViewModel.accept([item])
            }
            selectedCellViewModel.value.forEach { item in
                for cellViewModel in sectionItems {
                    if item.item.productId == cellViewModel.item.productId {
                        cellViewModel.selected.accept(true)
                        break
                    }
                }
            }
            let sections = [SectionModel<Void,VisualSearchResultCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        input.selection.subscribe(onNext: { cellViewModel in
            cellViewModel.selected.accept(!cellViewModel.selected.value)
            let selected = elements.value.map { $0.items }.flatMap { $0.filter { $0.selected.value } }
            selectedCellViewModel.accept(selected)
            
            
            
        }).disposed(by: rx.disposeBag)

        
        
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []))
    }
}
