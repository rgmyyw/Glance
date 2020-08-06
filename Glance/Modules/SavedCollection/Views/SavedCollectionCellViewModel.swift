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
    let delete = PublishSubject<Void>()
    
    var col : CGFloat = 2
    
    var height : CGFloat {
        let inset : CGFloat = 20
        let cellWidth : CGFloat = UIScreen.width - (inset * 2.0) - ((col - 1.0) * 15.0)
        if let urlParameters = item.image?.urlParameters() {
            let width = urlParameters["w"]?.cgFloat() ?? 0
            let height = urlParameters["h"]?.cgFloat() ?? 0
            var imageHeight = ((cellWidth / width) * height) / col
            if imageHeight.isNaN {
                imageHeight = 200
            }
            return imageHeight
        } else {
            return 200
        }
    }
    
    
    required init(item : Home) {
        self.item = item
        
        title.accept(item.title)
        imageURL.accept(item.image?.url)

    }
}
