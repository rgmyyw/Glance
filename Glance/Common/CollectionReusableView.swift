//
//  CollectionReusableView.swift
//  
//
//  Created by yanghai on 2019/12/16.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CollectionReusableView: UICollectionReusableView {
    
    var cellDisposeBag = DisposeBag()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    func makeUI() {
        
    }

    func updateUI() {
        setNeedsDisplay()
    }
    
    
    public func bind<T : CellViewModelProtocol>(to viewModel : T) {
        cellDisposeBag = DisposeBag()
    }

    
    
    
    
}
