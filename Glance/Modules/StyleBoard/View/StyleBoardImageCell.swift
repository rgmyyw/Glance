//
//  StyleBoardImageCell.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class StyleBoardImageCell: CollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var deleteButton: UIButton!

    override func makeUI() {
        super.makeUI()

//        let shadowOffset = CGSize(width: 1, height: 1)
//        let color = UIColor(hex:0x828282)!
//        let opacity : CGFloat = 0.05
//        containerView.shadow(cornerRadius: 5, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 2)
//        contentView.clipsToBounds = false
//        clipsToBounds = false

        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.primary().cgColor
        imageView.layer.masksToBounds = true
    }

    override func bind<T>(to viewModel: T) where T: StyleBoardImageCellViewModel {
        super.bind(to: viewModel)

        viewModel.empty.map { !$0}.bind(to: emptyView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.empty.bind(to: containerView.rx.isHidden).disposed(by: cellDisposeBag)
        viewModel.image.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.selected.map { $0 ? 1.5 : 0 }.bind(to: imageView.rx.borderWidth).disposed(by: cellDisposeBag)

        viewModel.selected.map { $0 ? 1.5 : 0 }.subscribe(onNext: { a in
//            print("productId: \(viewModel.item.productId ?? "")")
//            print("borderWidth: \(a)")
//            print("------------------------")
        }).disposed(by: cellDisposeBag)

        emptyView.rx.tap().bind(to: viewModel.add).disposed(by: cellDisposeBag)
        deleteButton.rx.tap.bind(to: viewModel.delete).disposed(by: cellDisposeBag)

    }

}
