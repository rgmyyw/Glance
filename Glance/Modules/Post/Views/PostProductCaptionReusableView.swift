//
//  PostProductNameReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostProductCaptionReusableView: CollectionReusableView {
    
    @IBOutlet weak var textView: UITextView!
    
    override func makeUI() {
        super.makeUI()
        //textView.addLeftTextPadding(12)
    }
    
    
    override func bind<T>(to viewModel: T) where T : PostProductSectionCellViewModel {
        super.bind(to: viewModel)
        
        (textView.rx.textInput <-> viewModel.caption).disposed(by: cellDisposeBag)
    }
}
