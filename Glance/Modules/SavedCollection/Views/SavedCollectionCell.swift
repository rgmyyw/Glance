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
    
    @IBOutlet weak var bgView: UIView!
    
    override func makeUI() {
        super.makeUI()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
        let shadowOffset = CGSize(width: 1, height: 1)
        let color = UIColor(hex:0x828282)!
        let opacity : CGFloat = 0.2
        bgView.shadow(cornerRadius: 8, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 15)
        contentView.clipsToBounds = false
        clipsToBounds = false
    }
    
    override func bind<T>(to viewModel: T) where T : SavedCollectionCellViewModel {
        super.bind(to: viewModel)
        
        imageViewHeight.constant = viewModel.imageHeight
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
