//
//  PostProductSectionCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/5.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostProductSectionCellViewModel: CellViewModelProtocol  {

    let item : Void
    
    let caption = BehaviorRelay<String>(value: "")
    
    let addTag = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    required init(item : Void) {
        self.item = item
    }

}
class PostProductCellViewModel: CellViewModelProtocol  {

    let item : VisualSearchDotCellViewModel
    
    let title = BehaviorRelay<String?>(value: nil)
    let imageURL = BehaviorRelay<URL?>(value: nil)
    
    let delete = PublishSubject<Void>()
    let edit = PublishSubject<Void>()
    
    required init(item : VisualSearchDotCellViewModel) {
        self.item = item
        
        imageURL.accept(item.selected?.image?.url)
        title.accept(item.selected?.title)
    }

}



