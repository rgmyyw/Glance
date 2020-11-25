//
//  ShoppingCartCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShoppingCartCellViewModel: CellViewModelProtocol {

    let item: ShoppingCart
    let imageURL = BehaviorRelay<URL?>(value: nil)
    let title = BehaviorRelay<NSAttributedString?>(value: nil)
    let price = BehaviorRelay<String?>(value: nil)
    let brand = BehaviorRelay<String?>(value: nil)
    let currency = BehaviorRelay<String?>(value: nil)

    let delete = PublishSubject<Void>()
    let comparePrice = PublishSubject<Void>()
    let buy = PublishSubject<Void>()

    required init(item: ShoppingCart) {

        self.item = item
        self.imageURL.accept(item.image?.url)
        self.price.accept(item.price)
        self.brand.accept(item.brand)
        self.currency.accept(item.currency)

        if let providerName = item.providerName, let text = item.productTitle {
            let attrTitle = NSMutableAttributedString(string: "\(providerName) \(text)", attributes: [ .foregroundColor: UIColor.text()])
            attrTitle.addAttributes([.font: UIFont.titleBoldFont(15)], range: NSRange(location: 0, length: providerName.count))
            title.accept(attrTitle)
        }

    }

}
