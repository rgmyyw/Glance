//
//  AddProductCategaryReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit



class AddProductCategaryReusableView: CollectionReusableView {

    @IBOutlet weak var button: UIButton!
    
    override func makeUI() {
        super.makeUI()

        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    override func bind<T>(to viewModel: T) where T : AddProductSectionCellViewModel {
        super.bind(to: viewModel)
        button.rx.tap.bind(to: viewModel.selectionCategory).disposed(by: cellDisposeBag)
        viewModel.selectedCategoryName.bind(to: button.rx.title(for: .normal)).disposed(by: cellDisposeBag)
        
    }
}
