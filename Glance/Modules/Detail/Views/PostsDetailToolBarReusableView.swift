//
//  PostsDetailToolBarReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostsDetailToolBarReusableView: CollectionReusableView {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    override func bind<T>(to viewModel: T) where T: PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)

        viewModel.recommended.bind(to: recommendButton.rx.isSelected ).disposed(by: cellDisposeBag)
        viewModel.recommendedButtonHidden.bind(to: recommendButton.rx.isHidden ).disposed(by: cellDisposeBag)
        viewModel.liked.bind(to: likeButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.saved.bind(to: saveButton.rx.isSelected).disposed(by: cellDisposeBag)

        likeButton.rx.tap.bind(to: viewModel.like).disposed(by: cellDisposeBag)
        saveButton.rx.tap.bind(to: viewModel.save).disposed(by: cellDisposeBag)
        recommendButton.rx.tap.bind(to: viewModel.recommend).disposed(by: cellDisposeBag)

    }

}
