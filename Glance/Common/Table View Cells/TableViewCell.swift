//
//  TableViewCell.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class TableViewCell: UITableViewCell {

    var cellDisposeBag : DisposeBag!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    

    func makeUI() {
        layer.masksToBounds = true
        selectionStyle = .none
        backgroundColor = .clear

        updateUI()
    }
    
    func bind<T : CellViewModelProtocol>(to viewModel : T) {
        cellDisposeBag = DisposeBag()
    }
    
    
    func updateUI() {
        setNeedsDisplay()
    }
}


