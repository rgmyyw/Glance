//
//  PostRecommendCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostRecommendCell: DefaultColltionCell {
        
    @IBOutlet weak var userHeadImageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userOnlineImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    
    override func makeUI() {
        super.makeUI()
        
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    override func bind<T>(to viewModel: T) where T : DefaultColltionCellViewModel {
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
    }
    
    
    
}
