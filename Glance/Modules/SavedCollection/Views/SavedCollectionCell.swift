//
//  SavedCollectionCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class SavedCollectionCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    
    override func makeUI() {
        super.makeUI()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override func bind<T>(to viewModel: T) where T : SavedCollectionCellViewModel {
        super.bind(to: viewModel)
        
        imageViewHeight.constant = viewModel.height
        imageView.backgroundColor = .lightGray
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        //viewModel.deleteButtonHidden.bind(to: deleteButton.rx.isHidden).disposed(by: cellDisposeBag)
        deleteButton.rx.tap.bind(to: viewModel.delete).disposed(by: cellDisposeBag)
        viewModel.deleteButtonHidden.map { !$0 }.subscribe(onNext: {[weak self] (alpha) in
            UIView.animate(withDuration: 0.25) {
                self?.deleteButton.alpha = alpha.int.cgFloat
            }
        }).disposed(by: cellDisposeBag)
    }
    
}
