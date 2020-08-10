//
//  PostProductInputKeywordReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostProductInputKeywordReusableView: CollectionReusableView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var currentInputLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func makeUI() {
        super.makeUI()
        textField.addLeftTextPadding(12)
        textField.limitCharacter(number: 50)
        
    }

    override func bind<T>(to viewModel: T) where T : PostProductSectionCellViewModel {
        super.bind(to: viewModel)
        
        addButton.rx.tap.map { self.textField.text }.filterNil().filterEmpty()
            .bind(to: viewModel.addTag).disposed(by: cellDisposeBag)
        addButton.rx.tap.map { "" }.bind(to: textField.rx.text).disposed(by: cellDisposeBag)
        textField.rx.text.filterNil().map { "\($0.count)/50"}
            .bind(to: currentInputLabel.rx.text).disposed(by: cellDisposeBag)
        
    }
}
