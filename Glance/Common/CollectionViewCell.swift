//
//  CollectionViewCell.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class CollectionViewCell: UICollectionViewCell {
    
    var cellDisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    func makeUI() {
        self.layer.masksToBounds = true
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }
    
    func bind<T : CellViewModelProtocol>(to viewModel : T) {
        cellDisposeBag = DisposeBag()
    }

}
