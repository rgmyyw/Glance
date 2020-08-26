//
//  PostsDetailCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostsDetailCell: CollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var saveImageView: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    override func bind<T>(to viewModel: T) where T : PostsDetailCellViewModel {
        super.bind(to: viewModel)
                
        imageViewHeight.constant = viewModel.imageHeight
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.saved.bind(to: saveImageView.rx.isSelected).disposed(by: cellDisposeBag)
        saveImageView.rx.tap.bind(to: viewModel.save).disposed(by: cellDisposeBag)
        
    }

    
    override func makeUI() {
        super.makeUI()
        

//        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//
//        imageView.clipsToBounds = true
//        clipsToBounds = false
//        bgView.clipsToBounds = false
//        shadowView.clipsToBounds = false
//        
//        let shadowOffset = CGSize(width: 0, height: 1)
//        let color = UIColor(hex:0x999999)!
//        let opacity : CGFloat = 0.14
//        shadowView.shadow(cornerRadius: 10, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 12)

    }
}
