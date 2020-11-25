//
//  AddProductTagCell.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class AddProductTagCell: CollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func bind<T>(to viewModel: T) where T: AddProductTagCellViewModel {
        super.bind(to: viewModel)
        deleteButton.rx.tap.bind(to: viewModel.delete).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: label.rx.text).disposed(by: cellDisposeBag)
    }

}
