//
//  VisualSearchProductCell.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchProductCell: CollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    
    override func bind<T>(to viewModel: T) where T : VisualSearchProductCellViewModel {
        super.bind(to: viewModel)
        imageViewHeight.constant = viewModel.height
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
    }
    
    
    override func makeUI() {
        super.makeUI()

        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        imageView.clipsToBounds = true
        clipsToBounds = false
        bgView.clipsToBounds = false
        shadowView.clipsToBounds = false
        
        let shadowOffset = CGSize(width: 0, height: 1)
        let color = UIColor(hex:0x999999)!
        let opacity : CGFloat = 0.14
        shadowView.shadow(cornerRadius: 10, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 12)
        
    }
    
    
}
