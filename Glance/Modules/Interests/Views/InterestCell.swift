//
//  InterestCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class InterestCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var bgView: UIView!

    override func makeUI() {
        super.makeUI()
        bgView.backgroundColor = .random
    }

    override func bind<T>(to viewModel: T) where T: InterestCellViewModel {
        super.bind(to: viewModel)

        viewModel.selected.bind(to: selectButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
    }
}
