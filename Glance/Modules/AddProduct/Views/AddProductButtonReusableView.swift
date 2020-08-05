//
//  AddProductButtonReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class AddProductButtonReusableView: CollectionReusableView {
    
    @IBOutlet weak var commitButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func bind<T>(to viewModel: T) where T : AddProductSectionCellViewModel {
        super.bind(to: viewModel)
        
        commitButton.rx.tap.bind(to: viewModel.commit).disposed(by: cellDisposeBag)
    }

}
