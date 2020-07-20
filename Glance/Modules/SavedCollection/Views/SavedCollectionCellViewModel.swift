//
//  SavedCollectionCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SavedCollectionCellViewModel : CellViewModelProtocol {
    
    let item : Home
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let deleteButtonHidden = BehaviorRelay<Bool>(value: true)
    
    required init(item : Home) {
        self.item = item
        
        title.accept(item.title)
        imageURL.accept(item.image?.url)

    }
}
