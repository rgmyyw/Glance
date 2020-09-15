//
//  SearchCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class SearchCell: TableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func makeUI() {
        super.makeUI()
        
    }
    
    override func bind<T>(to viewModel: T) where T : SearchCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.attr.bind(to: titleLabel.rx.attributedText).disposed(by: cellDisposeBag)
    }
}
