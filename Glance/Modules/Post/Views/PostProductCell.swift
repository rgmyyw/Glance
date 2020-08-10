//
//  PostProductCell.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostProductCell: CollectionViewCell {

    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func makeUI() {
        super.makeUI()
        
        let shadowOffset = CGSize(width: 1, height: 1)
        let color = UIColor(hex:0x828282)!
        let opacity : CGFloat = 0.2
        bgView.shadow(cornerRadius: 8, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 15)
        contentView.clipsToBounds = false
        clipsToBounds = false

    }
    
    
    
    override func bind<T>(to viewModel: T) where T : PostProductCellViewModel {
        super.bind(to: viewModel)

        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        editView.rx.tap().bind(to: viewModel.edit).disposed(by: cellDisposeBag)
    }
    

}
