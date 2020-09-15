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
    
    let element : BehaviorRelay<PageMapable<SearchTheme>?> = BehaviorRelay(value: nil)
    let themeClassify = BehaviorRelay<[SearchThemeClassify]>(value:[])

    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,SearchRecommendHotCellViewModel>]>(value: [])
        let filter = BehaviorRelay<[SectionModel<Void,SearchRecommendHotFilterCellViewModel>]>(value: [])
        let themeClassifySelection = BehaviorRelay<SearchRecommendHotFilterCellViewModel?>(value: nil)
        input.filter.bind(to: themeClassifySelection).disposed(by: rx.disposeBag)
        
        themeClassifySelection.subscribe(onNext: { (cellViewModel) in
            filter.value.first.value?.items.forEach { $0.selected.accept(false)}
            cellViewModel?.selected.accept(true)
        }).disposed(by: rx.disposeBag)
        
        
        Observable.just(())
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<[SearchThemeClassify]>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.searchThemeClassify()
                    .trackError(self.error)
                    .trackActivity(self.loading)
                    .materialize()
            }).subscribe(onNext: {[weak self] event in
                switch event {
                case .next(let item):
                    self?.themeClassify.accept(item)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        Observable.combineLatest(input.headerRefresh, input.filter)
            .flatMapLatest({ [weak self] (_,cellViewModel) -> Observable<(RxSwift.Event<PageMapable<SearchTheme>>)> in
                guard let self = self else {
                    return Observable.just(RxSwift.Event.completed)
                }
                self.page = 1
                return self.provider.searchThemeHot(classifyId: cellViewModel.item.classifyId, page: self.page)
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
        
        
        input.footerRefresh
            .flatMapLatest({ [weak self] (cellViewModel) -> Observable<RxSwift.Event<PageMapable<SearchTheme>>> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            if !(self.element.value?.hasNext ?? false) {
                return Observable.just(RxSwift.Event.completed)
            }
            self.page += 1
            let classifyId = themeClassifySelection.value?.item.classifyId ?? 0
            return self.provider.searchThemeHot(classifyId:classifyId , page: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = (self.element.value?.list ?? []) + item.list
                self.element.accept(temp)
                self.hasData.onNext(item.hasNext)
                
            default:
                break
            }
        }).disposed(by: rx.disposeBag)

        
        element.filterNil().map { element -> [SectionModel<Void,SearchRecommendHotCellViewModel>] in
            let sectionItems = element.list.map { item -> SearchRecommendHotCellViewModel  in
                let viewModel = SearchRecommendHotCellViewModel(item: item)
                return viewModel
            }
            let sections = [SectionModel<Void,SearchRecommendHotCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
            
        themeClassify.map { items -> [SectionModel<Void,SearchRecommendHotFilterCellViewModel>] in
            let sectionItems = items.map { item -> SearchRecommendHotFilterCellViewModel  in
                let viewModel = SearchRecommendHotFilterCellViewModel(item: item)
                return viewModel
            }
            themeClassifySelection.accept(sectionItems.first)
            let sections = [SectionModel<Void,SearchRecommendHotFilterCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: filter).disposed(by: rx.disposeBag)
    
        
        
        
    
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      filter: filter.asObservable())
        
    }
}
