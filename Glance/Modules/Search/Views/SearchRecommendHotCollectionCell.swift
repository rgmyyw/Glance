//
//  SearchRecommendHotCollectionCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class SearchRecommendHotCollectionCell: CollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func makeUI() {
        super.makeUI()
        
    }
    
    override func bind<T>(to viewModel: T) where T : SearchRecommendHotColltionCellViewModel {
        super.bind(to: viewModel)
        viewModel.image.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: userNameLabel.rx.text).disposed(by: cellDisposeBag)
    }
}
