//
//  PostsDetailTitleReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/7/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostsDetailTitleReusableView: CollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func makeUI() {
        super.makeUI()
        titleLabel.preferredMaxLayoutWidth = UIScreen.width - 20 * 2
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override func bind<T>(to viewModel: T) where T : PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)
        viewModel.postTitle.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
    }
}
