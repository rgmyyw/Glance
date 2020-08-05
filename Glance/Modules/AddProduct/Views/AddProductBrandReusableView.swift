//
//  AddProductBrandReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class AddProductBrandReusableView: CollectionReusableView {

    @IBOutlet weak var textField: UITextField!
    
    override func makeUI() {
        super.makeUI()
        textField.addLeftTextPadding(12)
    }
    override func bind<T>(to viewModel: T) where T : AddProductSectionCellViewModel {
        super.bind(to: viewModel)
        
        (textField.rx.textInput <-> viewModel.brand).disposed(by: cellDisposeBag)
    }

}
