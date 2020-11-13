//
//  NotificationThemeCell.swift
//  Glance
//
//  Created by yanghai on 2020/11/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class NotificationThemeCell: NotificationCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var unreadImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
    
    override func makeUI() {
        super.makeUI()
        
        stackView.addArrangedSubview(containerView)
    }
    
    override func bind<T>(to viewModel: T) where T : NotificationCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.theme.bind(to: themeLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.unread.bind(to: unreadImageView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.time.bind(to: timeLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.themeImages.value.enumerated().forEach { (offset, imageURL) in
            if offset < imageViews.count {
                imageURL.bind(to: imageViews[offset].rx.imageURL)
                    .disposed(by: cellDisposeBag)
            }
        }
    }

}