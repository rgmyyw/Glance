//
//  HomeCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwiftExt

class XHomeCell: CollectionViewCell {

    @IBOutlet weak var userHeadImageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var userContentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userOnlineImageView: UIImageView!
    @IBOutlet weak var favorite: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!

    override func makeUI() {
        super.makeUI()
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//UIImageView().zl_enlargeValidTouchArea(withInset: 10)

    }

    override func bind<T>(to viewModel: T) where T: DefaultColltionCellViewModel {
        super.bind(to: viewModel)

        imageView.backgroundColor = .lightGray
        imageViewHeight.constant = viewModel.imageHeight
        viewModel.userHeadImageURL.bind(to: userHeadImageButton.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userName.bind(to: userNameLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.typeName.bind(to: typeLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.userHidden.bind(to: userContentView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userOnline.map { !$0}.bind(to: userOnlineImageView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.emojiButtonHidden.bind(to: emojiButton.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.saved.bind(to: favorite.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.recommendButtonHidden.bind(to: recommendButton.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.recommended.bind(to: recommendButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.reactionImage.bind(to: emojiButton.rx.image(for: .normal)).disposed(by: cellDisposeBag)

        favorite.rx.tap.bind(to: viewModel.save).disposed(by: cellDisposeBag)
        likeButton.rx.tap.map { self.likeButton }.bind(to: viewModel.reaction).disposed(by: cellDisposeBag)
        recommendButton.rx.tap.bind(to: viewModel.recommend).disposed(by: cellDisposeBag)
        userHeadImageButton.rx.tap.bind(to: viewModel.userDetail).disposed(by: cellDisposeBag)
    }

}
