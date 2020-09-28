//
//  SearchRecommendHotFilterCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchRecommendHotFilterCellViewModel: CellViewModelProtocol  {

    let item : SearchThemeClassify
    let title = BehaviorRelay<String?>(value: nil)
    let selected = BehaviorRelay<Bool>(value: false)
    
    
    
    
    required init(item : SearchThemeClassify) {
        self.item = item
        title.accept(item.classifyName)
        
    }
    
    func backgroundColor() -> Observable<UIColor?>{
        return selected.map { $0 ? UIColor.primary() : UIColor(hex:0xF5F5F5)}
    }
    
    func textColor() -> Observable<UIColor?>{
        return selected.map { $0 ? UIColor.white : UIColor.textGray()}
    }
    
}
