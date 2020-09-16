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

    let item : SearchTheme
    let title = BehaviorRelay<String?>(value: nil)
    let post = BehaviorRelay<String?>(value: nil)
    
    let selection = PublishSubject<Void>()
    let items = BehaviorRelay<[SectionModel<Void, SearchRecommendHotColltionCellViewModel>]>(value: [])
    
    let themeDetail = PublishSubject<Void>()
    
    required init(item : SearchTheme) {
        self.item = item
        
        title.accept(item.title)
        post.accept("  \(item.postCount.format()) Post  ")
        let elements = item.postList.map { SearchRecommendHotColltionCellViewModel(item: $0) }
        items.accept([SectionModel<Void,SearchRecommendHotColltionCellViewModel>(model: (), items: elements)])
    }

}

class SearchRecommendHotColltionCellViewModel: CellViewModelProtocol  {

    let item : SearchThemeItem
    let image = BehaviorRelay<URL?>(value: nil)
    let title = BehaviorRelay<String?>(value: nil)
    let selection = PublishSubject<Void>()
    
    required init(item : SearchThemeItem) {
        self.item = item
        title.accept(item.displayInfo)
        image.accept(item.image?.url)
    }

}
