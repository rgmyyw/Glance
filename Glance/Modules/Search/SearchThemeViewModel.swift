//
//  SearchThemeViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchThemeViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let refresh : Observable<Void>
        let updateHistory : Observable<Void>
    }
    
    struct Output {
        let config : Driver<[SearchThemeModuleItem]>
        let labels : Driver<[SectionModel<Void,SearchThemeLabelCellViewModel>]>
    }
    
    let element = BehaviorRelay<SearchThemeDetail?>(value: nil)
    let themeId : BehaviorRelay<Int>
    
    init(provider: API, themeId : Int) {
        self.themeId = BehaviorRelay(value: themeId)
        super.init(provider: provider)
        
    }
    
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,SearchThemeLabelCellViewModel>]>(value: [])
        
        let config = elements.filterEmpty().mapToVoid().map { () -> [SearchThemeModuleItem] in
            let themeId = self.themeId.value
            let all = SearchThemeContentViewModel(provider: self.provider, type: .all,themeId: themeId)
            let product = SearchThemeContentViewModel(provider: self.provider, type: .product,themeId: themeId)
            let post = SearchThemeContentViewModel(provider: self.provider, type: .post,themeId: themeId)
            let user = SearchThemeContentViewModel(provider: self.provider, type: .user,themeId: themeId)
            let items : [SearchThemeModuleItem] = [.all(viewModel: all),.product(viewModel: product),.post(viewModel: post),.user(viewModel: user)]
            return items
        }
        
        element.filterNil().map { element -> [SectionModel<Void,SearchThemeLabelCellViewModel>] in
            let items = element.label.map { SearchThemeLabelCellViewModel(item: $0)}
            return [SectionModel<Void,SearchThemeLabelCellViewModel>(model: (), items: items )]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        themeId.flatMapLatest({ [weak self] (themeId) -> Observable<(RxSwift.Event<SearchThemeDetail>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            return self.provider.searchThemeDetail(themeId: themeId)
                .trackError(self.error)
                .trackActivity(self.loading)
                .materialize()
        }).subscribe(onNext: {[weak self] event in
            switch event {
            case .next(let item):
                self?.element.accept(item)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
    
        
        
        return Output(config: config.asDriver(onErrorJustReturn: []),
                      labels: elements.asDriver(onErrorJustReturn: [])
        )
    }
}

