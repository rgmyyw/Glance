//
//  UserPostCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwiftExt

class UserPostCell: CollectionViewCell {
    
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favorite: UIButton!

    override func bind<T>(to viewModel: T) where T : UserPostCellViewModel {
        super.bind(to: viewModel)
    
        imageView.backgroundColor = .lightGray

        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.isFavorite.bind(to: favorite.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.recommendButtonHidden.bind(to: recommendButton.rx.isHidden).disposed(by: cellDisposeBag)
        favorite.rx.tap.bind(to: viewModel.saveFavorite).disposed(by: cellDisposeBag)
    }

}
