//
//  ShoppingCartCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ShoppingCartCell: TableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var comparePriceButton: UIButton!
    
    
    override func makeUI() {
        super.makeUI()
        
        let shadowOffset = CGSize(width: 0, height: 1)
        let color = UIColor(hex:0x828282)!.withAlphaComponent(0.2)
        let opacity : CGFloat = 1
        bgView.shadow(cornerRadius: 8, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 5)
        
    }
    
    override func bind<T>(to viewModel: T) where T : ShoppingCartCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.imageURL.bind(to: productImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.price.map { "\(viewModel.currency.value ?? "")\($0 ?? "0")"}.bind(to: priceLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.brand.bind(to: brandLabel.rx.text).disposed(by: cellDisposeBag)
        deleteButton.rx.tap.bind(to: viewModel.delete).disposed(by: cellDisposeBag)
        comparePriceButton.rx.tap.bind(to: viewModel.comparePrice).disposed(by: cellDisposeBag)
    }
    
    
}
