//
//  UserRecommCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwiftExt

class UserRecommCell: CollectionViewCell {
    
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favorite: UIButton!
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    
    override func makeUI() {
        super.makeUI()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    
    override func bind<T>(to viewModel: T) where T : UserRecommCellViewModel {
        super.bind(to: viewModel)
    
        imageView.backgroundColor = .lightGray
        imageViewHeight.constant = viewModel.imageHeight
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.isFavorite.bind(to: favorite.rx.isSelected).disposed(by: cellDisposeBag)
        //viewModel.recommendButtonHidden.bind(to: recommendButton.rx.isHidden).disposed(by: cellDisposeBag)
        favorite.rx.tap.bind(to: viewModel.saveFavorite).disposed(by: cellDisposeBag)
    }

}
