//
//  VisualSearchResultCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/30.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class StyleBoardSearchCell: CollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
        
    
    override func bind<T>(to viewModel: T) where T : StyleBoardSearchCellViewModel {
        super.bind(to: viewModel)
        
        imageViewHeight.constant = viewModel.imageHeight
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.selected.bind(to: selectionButton.rx.isSelected).disposed(by: cellDisposeBag)
        selectionButton.rx.tap.bind(to: viewModel.selection).disposed(by: cellDisposeBag)
    }
    
    
    override func makeUI() {
        super.makeUI()
        
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
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
