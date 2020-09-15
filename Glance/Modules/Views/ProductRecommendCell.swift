//
//  ProductRecommendCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class ProductRecommendCell: DefaultColltionCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    override func makeUI() {
        super.makeUI()
        
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    
    override func bind<T>(to viewModel: T) where T : DefaultColltionCellViewModel {
        super.bind(to: viewModel)
        
        imageView.backgroundColor = .lightGray
        imageViewHeight.constant = viewModel.imageHeight
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.saved.bind(to: saveButton.rx.isSelected).disposed(by: cellDisposeBag)
        saveButton.rx.tap.bind(to: viewModel.save).disposed(by: cellDisposeBag)
    }
}
