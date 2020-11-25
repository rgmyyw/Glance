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
    @IBOutlet weak var storeNameLabel: UILabel!

    override func makeUI() {
        super.makeUI()

    }

    override func bind<T>(to viewModel: T) where T: PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)

        bgView.rx.tap().bind(to: viewModel.selectStore).disposed(by: cellDisposeBag)
        viewModel.price.bind(to: priceLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.storeName.bind(to: storeNameLabel.rx.text).disposed(by: cellDisposeBag)
    }

}
