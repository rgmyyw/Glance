//
//  HomeCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwiftExt

class HomeCell: CollectionViewCell {
    
    @IBOutlet weak var userHeadImageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var userContentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userOnlineImageView: UIImageView!
    
    override func bind<T>(to viewModel: T) where T : HomeCellViewModel {
        super.bind(to: viewModel)
    
        imageView.backgroundColor = .lightGray
        
        viewModel.userHeadImageURL.bind(to: userHeadImageButton.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userName.bind(to: userNameLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.typeName.bind(to: typeLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.userHidden.bind(to: userContentView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userOnline.map { !$0}.bind(to: userOnlineImageView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.emojiButtonHidden.bind(to: emojiButton.rx.isHidden).disposed(by: cellDisposeBag)


        
    }

}
