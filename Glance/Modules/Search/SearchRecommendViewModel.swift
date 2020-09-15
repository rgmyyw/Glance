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
        let refresh : Observable<Void>
        let clearAll : Observable<Void>
        let updateHistory : Observable<Void>
        let search : Observable<Void>
    }
    
    struct Output {
        let config : Driver<[SearchRecommendModuleItem]>
        let history : Driver<[SearchRecommendHistorySection]>
        let headHidden : Driver<Bool>
        let search : Driver<Void>
    }
    

    func transform(input: Input) -> Output {
        
        let history = BehaviorRelay<[SearchHistoryItem]>(value: [])
        let eraseHistory = PublishSubject<[SearchHistoryItem]>()
        let elements = BehaviorRelay<[SearchRecommendHistorySection]>(value:[])
        let headHidden = BehaviorRelay<Bool>(value: true)
        
        input.updateHistory.map { searchHistory.value }.bind(to: history).disposed(by: rx.disposeBag)
        input.clearAll.map { searchHistory.value } .bind(to: eraseHistory).disposed(by: rx.disposeBag)
        history.map { $0.isEmpty }.bind(to: headHidden).disposed(by: rx.disposeBag)
        
        let config = Observable<[SearchRecommendModuleItem]>.create { (observer) -> Disposable in
            let hot = SearchRecommendHotViewModel(provider: self.provider)
            let youMayLike = SearchRecommendYouMayLikeViewModel(provider: self.provider)
            let new = SearchRecommendNewViewModel(provider: self.provider)
            let items : [SearchRecommendModuleItem] = [.hot(viewModel: hot),.youMayLike(viewModel: youMayLike),.new(viewModel: new)]
            observer.onNext(items)
            observer.onCompleted()
            return Disposables.create { }
        }
    
        
        history.map { items -> [SearchRecommendHistorySection] in
            let section = 0
            return [SearchRecommendHistorySection(section: "section:\(section)", elements: items.enumerated().map { (index, item) -> SearchRecommendHistorySectionItem in
                let viewModel = SearchHistoryCellViewModel(item: item)
                viewModel.delete.map { [item]}.bind(to: eraseHistory).disposed(by: self.rx.disposeBag)
                let item = SearchRecommendHistorySectionItem(item: "section:\(section)item:\(index)", viewModel: viewModel)
                return item
            })]
        }.bind(to: elements)
            .disposed(by: rx.disposeBag)

        (1...3).forEach { (_) in
            SearchHistoryItem(text: String.random(ofLength: Int.random(in: 10...30))).save()
        }
        
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
                      search: input.search.asDriver(onErrorJustReturn: ()))
    }
}

