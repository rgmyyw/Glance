//
//  VisualSearchProductReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/8/24.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchProductReusableView: CollectionReusableView {

    @IBOutlet weak var addButton: UIButton!

    override func bind<T>(to viewModel: T) where T: VisualSearchProductEmptyCellModel {
        super.bind(to: viewModel)
        addButton.rx.tap.bind(to: viewModel.add).disposed(by: cellDisposeBag)
    }
}
