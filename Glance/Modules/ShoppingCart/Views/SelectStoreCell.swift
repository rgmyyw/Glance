//
//  SelectStoreCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class SelectStoreCell: TableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var attributeLabel: UIButton!
    @IBOutlet weak var buyArrowButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var addShoppingCartButton: UIButton!
    
    override func makeUI() {
        super.makeUI()
        
    }
    
    
    override func bind<T>(to viewModel: T) where T : SelectStoreCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.imageURL.bind(to: productImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.attributedText).disposed(by: cellDisposeBag)
        viewModel.price.bind(to: priceLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.attribute.bind(to: attributeLabel.rx.title(for: .normal)).disposed(by: cellDisposeBag)
        viewModel.availability.bind(to: stockLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.inShoppingList.map { !$0}.bind(to: addShoppingCartButton.rx.isEnabled).disposed(by: cellDisposeBag)
        viewModel.inShoppingList.map { !$0}.bind(to: buyButton.rx.isEnabled).disposed(by: cellDisposeBag)
        viewModel.inShoppingList.map { !$0}.bind(to: buyArrowButton.rx.isEnabled).disposed(by: cellDisposeBag)
        viewModel.inShoppingList.map { !$0}.bind(to: attributeLabel.rx.isEnabled).disposed(by: cellDisposeBag)

        
        viewModel.displaying.map {!$0}.bind(to: stateView.rx.isHidden).disposed(by: cellDisposeBag)
        buyButton.rx.tap.asObservable().merge(with: buyArrowButton.rx.tap.asObservable()).bind(to: viewModel.buy).disposed(by: cellDisposeBag)
        
        
        addShoppingCartButton.rx.tap.bind(to: viewModel.addShoppingCart).disposed(by: cellDisposeBag)
    }
}
