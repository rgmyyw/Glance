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
    
    

    override func bind<T>(to viewModel: T) where T : SavedCollectionCellViewModel {
        super.bind(to: viewModel)
    
        imageView.backgroundColor = .lightGray
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.deleteButtonHidden.bind(to: deleteButton.rx.isHidden).disposed(by: cellDisposeBag)
                
        viewModel.imageURL.subscribe(onNext: { [weak self]url in
            guard let url = url else { return }
        
//            self?.imageView.kf.setImage(with: resource, placeholder: UIImage(), options: nil, progressBlock: nil) { (result) in
//
//            }

        }).disposed(by: cellDisposeBag)
    }

}
