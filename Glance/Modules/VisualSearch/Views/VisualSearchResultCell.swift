//
//  VisualSearchResultCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/30.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchResultCell: CollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!

    override func bind<T>(to viewModel: T) where T: DefaultColltionCellViewModel {
        super.bind(to: viewModel)

        imageViewHeight.constant = viewModel.imageHeight
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.selected.bind(to: selectionButton.rx.isSelected).disposed(by: cellDisposeBag)
        saveButton.rx.tap.bind(to: viewModel.save).disposed(by: cellDisposeBag)
    }

    override func makeUI() {
        super.makeUI()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
