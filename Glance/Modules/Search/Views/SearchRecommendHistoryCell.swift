//
//  SearchRecommendHistoryCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class SearchRecommendHistoryCell: CollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
    }
    
    override func bind<T>(to viewModel: T) where T : SearchHistoryCellViewModel {
        super.bind(to: viewModel)
        
        deleteButton.rx.tap.bind(to: viewModel.delete).disposed(by: cellDisposeBag)
        viewModel.title.bind(to: label.rx.text).disposed(by: cellDisposeBag)
    }
}
