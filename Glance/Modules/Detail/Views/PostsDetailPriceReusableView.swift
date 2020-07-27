//
//  PostsDetailPriceReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostsDetailPriceReusableView: CollectionReusableView {
    
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var bgView: UIView!

    override func makeUI() {
        super.makeUI()
        
        //bgView.backgroundColor = .random
    }
    
    
    override func bind<T>(to viewModel: T) where T : PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.price.bind(to: priceLabel.rx.text).disposed(by: cellDisposeBag)
    }
    
}
