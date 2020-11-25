//
//  SearchRecommendViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchRecommendViewModel: ViewModel, ViewModelType {

    struct Input {
        let refresh: Observable<Void>
        let clearAll: Observable<Void>
        let search: Observable<Void>
        let historySelection: Observable<SearchRecommendHistorySectionItem>
        let camera: Observable<Void>
    }

    struct Output {
        let config: Driver<[SearchRecommendModuleItem]>
        let history: Driver<[SearchRecommendHistorySection]>
        let headHidden: Driver<Bool>
        let search: Driver<Void>
        let searchResult: Driver<String>
        let viSearch: Driver<Void>
    }

    func transform(input: Input) -> Output {

        let eraseHistory = PublishSubject<[SearchHistoryItem]>()
        let elements = BehaviorRelay<[SearchRecommendHistorySection]>(value: [])
        let headHidden = BehaviorRelay<Bool>(value: true)
        let searchResult = input.historySelection.map { $0.viewModel.item.text }.asDriverOnErrorJustComplete()

        input.clearAll.map { searchHistory.value } .bind(to: eraseHistory).disposed(by: rx.disposeBag)
        searchHistory.map { $0.isEmpty }.bind(to: headHidden).disposed(by: rx.disposeBag)

        let config = Observable<[SearchRecommendModuleItem]>.create { (observer) -> Disposable in
            let hot = SearchRecommendHotViewModel(provider: self.provider)
            let youMayLike = SearchRecommendYouMayLikeViewModel(provider: self.provider)
            let new = SearchRecommendNewViewModel(provider: self.provider)
            let items: [SearchRecommendModuleItem] = [.hot(viewModel: hot), .youMayLike(viewModel: youMayLike), .new(viewModel: new)]
            observer.onNext(items)
            observer.onCompleted()
            return Disposables.create { }
        }

        searchHistory.filterEmpty().map { (items) -> [SearchRecommendHistorySection] in
//            if elements.value.count != items.count {
                elements.accept([])
//            }
            return [SearchRecommendHistorySection(section: "section:\(0)", elements: items.enumerated().map { (index, item) -> SearchRecommendHistorySectionItem in
                let viewModel = SearchHistoryCellViewModel(item: item)
                viewModel.delete.map { [item]}.bind(to: eraseHistory).disposed(by: self.rx.disposeBag)
                let item = SearchRecommendHistorySectionItem(item: "section:\(0)item:\(index)", viewModel: viewModel)
                return item
            })]
        }.bind(to: elements)
            .disposed(by: rx.disposeBag)

        eraseHistory.subscribe(onNext: { items in
            SearchHistoryItem.remove(items: items)
            guard let section = elements.value.first else { return }
            var all = section.items
            items.forEach { item in
                if let index = all.firstIndex(where: { $0.viewModel.item == item}) {
                    all.remove(at: index)
                }
            }
            let sections = [SearchRecommendHistorySection(original: section, items: all)]
            headHidden.accept(all.isEmpty)
            elements.accept(all.isEmpty ? [] : sections)
        }).disposed(by: rx.disposeBag)

        return Output(config: config.asDriver(onErrorJustReturn: []),
                      history: elements.asDriver(onErrorJustReturn: []),
                      headHidden: headHidden.asDriver(),
                      search: input.search.asDriver(onErrorJustReturn: ()),
                      searchResult: searchResult,
                      viSearch: input.camera.asDriverOnErrorJustComplete())
    }
}
