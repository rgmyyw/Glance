//
//  SearchRecommendHotCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchRecommendHotCellViewModel: CellViewModelProtocol  {

    let item : Home
    let title = BehaviorRelay<String?>(value: nil)
    let post = BehaviorRelay<String?>(value: nil)
    
    let selection = PublishSubject<Void>()
    let items = BehaviorRelay<[SectionModel<Void, SearchRecommendHotColltionCellViewModel>]>(value: [])
    
    required init(item : Home) {
        self.item = item
        
        title.accept(String.random())
        post.accept("  \(CGFloat.random(in: 1...20))k Post  ")
        let i = (0...10).map { (_) -> SearchRecommendHotColltionCellViewModel  in
            let item = SearchRecommendHotColltionCellViewModel(item: item)
            return item
        }
        items.accept([SectionModel<Void,SearchRecommendHotColltionCellViewModel>(model: (), items: i)])
    }

}

class SearchRecommendHotColltionCellViewModel: CellViewModelProtocol  {

    let item : Home
    let image = BehaviorRelay<URL?>(value: nil)
    let title = BehaviorRelay<String?>(value: nil)
    let selection = PublishSubject<Void>()
    
    required init(item : Home) {
        self.item = item
        title.accept(String.random())
    }

}
