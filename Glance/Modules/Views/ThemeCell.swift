//
//  ThemeCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class ThemeCell: DefaultColltionCell {

    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var titleLabel: UILabel!

    override func makeUI() {
        super.makeUI()

    }

    override func bind<T>(to viewModel: T) where T: DefaultColltionCellViewModel {
        super.bind(to: viewModel)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.images.subscribe(onNext: { [weak self](items) in
            guard let self = self else { return }
            items.enumerated().forEach { offset, item in
                item.bind(to: self.imageViews[offset].rx.imageURL).disposed(by: self.cellDisposeBag)
            }
            }).disposed(by: cellDisposeBag)

    }

}
