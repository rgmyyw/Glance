//
//  SearchRecommendHotViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchRecommendHotViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let filter : Observable<SearchRecommendHotFilterCellViewModel>
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,SearchRecommendHotCellViewModel>]>
        let filter : Observable<[SectionModel<Void,SearchRecommendHotFilterCellViewModel>]>
    }
    
    let element : BehaviorRelay<PageMapable<Home>> = BehaviorRelay(value: PageMapable<Home>())
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,SearchRecommendHotCellViewModel>]>(value: [])
        let filter = BehaviorRelay<[SectionModel<Void,SearchRecommendHotFilterCellViewModel>]>(value: [])
        
        
        input.filter.subscribe(onNext: { (cellViewModel) in
            filter.value.first.value?.items.forEach { $0.selected.accept(false)}
            cellViewModel.selected.accept(true)
        }).disposed(by: rx.disposeBag)
        
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
                self.hasData.onNext(item.hasNext)
                
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        element.map { items -> [SectionModel<Void,SearchRecommendHotCellViewModel>] in
            let sectionItems = items.list.map { item -> SearchRecommendHotCellViewModel  in
                let viewModel = SearchRecommendHotCellViewModel(item: item)
                return viewModel
            }
            let sections = [SectionModel<Void,SearchRecommendHotCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
            
        element.map { items -> [SectionModel<Void,SearchRecommendHotFilterCellViewModel>] in
            let sectionItems = items.list.map { item -> SearchRecommendHotFilterCellViewModel  in
                let viewModel = SearchRecommendHotFilterCellViewModel(item: item)
                return viewModel
            }
            sectionItems.first?.selected.accept(true)
            let sections = [SectionModel<Void,SearchRecommendHotFilterCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: filter).disposed(by: rx.disposeBag)
    
        
        
        
    
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      filter: filter.asObservable())
        
    }
}
