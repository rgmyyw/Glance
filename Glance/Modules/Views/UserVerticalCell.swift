//
//  UserCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class UserVerticalCell: DefaultColltionCell {
    
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    override func makeUI() {
        super.makeUI()
        followButton.borderWidth = 0.5
        followButton.borderColor = UIColor.primary()
    }
    
    
    override func bind<T>(to viewModel: T) where T : DefaultColltionCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.userHeadImageURL.bind(to: userImageButton.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.userName.bind(to: userNameLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.followed.map { $0 ? "Following" : "+ Follow" }.bind(to: followButton.rx.title(for: .normal)).disposed(by: cellDisposeBag)
        viewModel.followed.map { $0 ? UIColor.primary() : UIColor.white }.bind(to: followButton.rx.titleColor(for: .normal)).disposed(by: cellDisposeBag)
        viewModel.followed.map { $0 ? .white : UIColor.primary() }.bind(to: followButton.rx.backgroundColor).disposed(by: cellDisposeBag)
        viewModel.displayName.bind(to: nickNameLabel.rx.text).disposed(by: cellDisposeBag)
        
    }
    
}
