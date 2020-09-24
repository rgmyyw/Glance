//
//  SelectStoreCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/21.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SelectStoreCellViewModel: CellViewModelProtocol  {

    let item : SelectStore
    let imageURL = BehaviorRelay<URL?>(value: nil)
    let title = BehaviorRelay<NSAttributedString?>(value: nil)
    let price = BehaviorRelay<String?>(value: nil)
    let availability = BehaviorRelay<String?>(value: nil)
    let attribute = BehaviorRelay<String?>(value: nil)
    let inShoppingList = BehaviorRelay<Bool>(value: true)
    
    let displaying = BehaviorRelay<Bool>(value: false)
    let addShoppingCart = PublishSubject<Void>()
    let buy = PublishSubject<Void>()
    
    required init(item : SelectStore) {
        
        
        
        self.item = item
        self.imageURL.accept(item.image?.url)
        self.price.accept(item.price)
        self.availability.accept(item.availability)
        self.attribute.accept(item.variants)
        self.inShoppingList.accept(item.inShoppingList)
        if let providerName = item.providerName, let text = item.title {
            let attrTitle = NSMutableAttributedString(string: "\(providerName) \(text)", attributes: [ .foregroundColor: UIColor.text()])
            attrTitle.addAttributes([.font : UIFont.titleBoldFont(15)], range: NSRange(location: 0, length: providerName.count))
            title.accept(attrTitle)
        }
    }

    
}
