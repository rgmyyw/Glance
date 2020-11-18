//
//  NotificationSystemCell.swift
//  Glance
//
//  Created by yanghai on 2020/11/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class NoticeSystemCell: NoticeCell {
    
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var unreadImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func makeUI() {
        super.makeUI()
        
        stackView.addArrangedSubview(containerView)
    }
    
    override func bind<T>(to viewModel: T) where T : NoticeCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.image.bind(to: postImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.description.bind(to: descriptionLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.unread.bind(to: unreadImageView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.time.bind(to: timeLabel.rx.text).disposed(by: cellDisposeBag)
        postImageView.rx.tap().bind(to: viewModel.postDetail).disposed(by: cellDisposeBag)
    }

}
