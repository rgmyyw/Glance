//
//  NotificationFollowingCell.swift
//  Glance
//
//  Created by yanghai on 2020/11/5.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class NoticeFollowingCell: NoticeCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var unreadImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!

    override func makeUI() {
        super.makeUI()

        stackView.addArrangedSubview(containerView)
    }

    override func bind<T>(to viewModel: T) where T: NoticeCellViewModel {
        super.bind(to: viewModel)

        viewModel.userImageURL.bind(to: userImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userName.bind(to: userNameLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.following.bind(to: followButton.rx.isSelected).disposed(by: cellDisposeBag)
        //viewModel.unread.bind(to: unreadImageView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.time.bind(to: timeLabel.rx.text).disposed(by: cellDisposeBag)
        userImageView.rx.tap().bind(to: viewModel.userDetail).disposed(by: cellDisposeBag)
        followButton.rx.tap.bind(to: viewModel.follow).disposed(by: cellDisposeBag)

    }

}
