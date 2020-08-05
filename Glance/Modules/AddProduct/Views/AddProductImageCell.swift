//
//  AddProductThumbnailCell.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class AddProductImageCell: CollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editButton: UIView!
    
    override func makeUI() {
        super.makeUI()

    }
    
    override func bind<T>(to viewModel: T) where T : AddProductImageCellViewModel {
        super.bind(to: viewModel)
        
        editButton.rx.tap().bind(to: viewModel.edit).disposed(by: cellDisposeBag)
        
        viewModel.image.bind(to: imageView.rx.image).disposed(by: cellDisposeBag)
    }
}
