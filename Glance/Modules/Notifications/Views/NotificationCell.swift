//
//  NotificationCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class NotificationCell: TableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var onlineImageView: UIImageView!
    
    override func makeUI() {
        super.makeUI()
        
        let shadowOffset = CGSize(width: 0, height: 1)
        let color = UIColor(hex:0x828282)!.withAlphaComponent(0.2)
        let opacity : CGFloat = 1
        bgView.shadow(cornerRadius: 8, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 5)
        
    }
    
    override func bind<T>(to viewModel: T) where T : NotificationCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.userImageURL.bind(to: userImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.time.bind(to: timeLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.isRead.bind(to: readButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.typeImage.bind(to: typeImageView.rx.image).disposed(by: cellDisposeBag)
        viewModel.online.bind(to: onlineImageView.rx.isHidden).disposed(by: cellDisposeBag)

    }
    
    
}
