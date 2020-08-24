//
//  AddProductWebsiteReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class AddProductWebsiteReusableView: CollectionReusableView {

    @IBOutlet weak var textField: UITextField!
    
    override func makeUI() {
        super.makeUI()
        
        textField.addPaddingLeft(12)
    }
    override func bind<T>(to viewModel: T) where T : AddProductSectionCellViewModel {
        super.bind(to: viewModel)
        
        (textField.rx.textInput <-> viewModel.website).disposed(by: cellDisposeBag)
    }

}
