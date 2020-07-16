//
//  PostsDetailHeadReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostsDetailHeadReusableView: CollectionReusableView {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    
    
    
    override func makeUI() {
        super.makeUI()
    }
    
    override func bind<T>(to viewModel: T) where T : PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)
        
        viewModel.postTitle.bind(to: postTitleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.postImageURL.bind(to: postImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.recommended.bind(to: recommendButton.rx.isSelected ).disposed(by: cellDisposeBag)
        viewModel.liked.bind(to: recommendButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.saved.bind(to: saveButton.rx.isSelected).disposed(by: cellDisposeBag)

        likeButton.rx.tap.bind(to: viewModel.like).disposed(by: cellDisposeBag)
        saveButton.rx.tap.bind(to: viewModel.save).disposed(by: cellDisposeBag)
        recommendButton.rx.tap.bind(to: viewModel.recommend).disposed(by: cellDisposeBag)
    }
    
    
}
