//
//  ProductRecommendCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class ProductRecommendCell: DefaultColltionCell {

    @IBOutlet weak var userHeadImageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var userOnlineImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!

    @IBOutlet weak var memuView: UIView!
    @IBOutlet var memuItems: [UIView]!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!

    override func makeUI() {
        super.makeUI()

        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    override func bind<T>(to viewModel: T) where T: DefaultColltionCellViewModel {
        super.bind(to: viewModel)

        imageView.backgroundColor = .lightGray
        imageViewHeight.constant = viewModel.imageHeight
        viewModel.userHeadImageURL.bind(to: userHeadImageButton.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userName.bind(to: userNameLabel.rx.text).disposed(by: cellDisposeBag)

        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userOnline.map { !$0}.bind(to: userOnlineImageView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.saved.bind(to: saveButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.reactionImage.bind(to: emojiButton.rx.image(for: .normal)).disposed(by: cellDisposeBag)

        saveButton.rx.tap.bind(to: viewModel.save).disposed(by: cellDisposeBag)
        emojiButton.rx.tap.map { self.emojiButton }.bind(to: viewModel.reaction).disposed(by: cellDisposeBag)
        userHeadImageButton.rx.tap.bind(to: viewModel.userDetail).disposed(by: cellDisposeBag)
        moreButton.rx.tap.bind(to: viewModel.more).disposed(by: cellDisposeBag)

        likeButton.rx.tap.bind(to: viewModel.like).disposed(by: cellDisposeBag)
        shareButton.rx.tap.bind(to: viewModel.share).disposed(by: cellDisposeBag)
        deleteButton.rx.tap.bind(to: viewModel.delete).disposed(by: cellDisposeBag)
        reportButton.rx.tap.bind(to: viewModel.report).disposed(by: cellDisposeBag)

        viewModel.memu.subscribe(onNext: { [weak self](items) in
            self?.memuItems.forEach { $0.isHidden = true }
            items.forEach { self?.memuItems[$0.rawValue].isHidden = false }
            }).disposed(by: cellDisposeBag)
        viewModel.memuHidden.subscribe(onNext: { [weak self](hidden) in
            UIView.animate(withDuration: 0.25) {
                self?.memuView.alpha =  (!hidden).int.cgFloat
            }
        }).disposed(by: cellDisposeBag)

    }
}
