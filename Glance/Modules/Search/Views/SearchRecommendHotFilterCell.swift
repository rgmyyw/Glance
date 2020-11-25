//
//  SearchRecommendHotFilterCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class SearchRecommendHotFilterCell: CollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func bind<T>(to viewModel: T) where T: SearchRecommendHotFilterCellViewModel {
        super.bind(to: viewModel)

        viewModel.backgroundColor().bind(to: bgView.rx.backgroundColor).disposed(by: cellDisposeBag)
        viewModel.textColor().bind(to: label.rx.textColor).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: label.rx.text).disposed(by: cellDisposeBag)
    }
}
