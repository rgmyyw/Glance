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
    @IBOutlet weak var labelTop: NSLayoutConstraint!

    override func makeUI() {
        super.makeUI()

        titleLabel.preferredMaxLayoutWidth = UIScreen.width - 20 * 2
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    override func bind<T>(to viewModel: T) where T: PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)

        viewModel.folded.subscribe(onNext: { [weak self](state) in
            self?.titleLabel.numberOfLines = state ? 3 : 0
            //self?.titleLabel.sizeToFit()
        }).disposed(by: cellDisposeBag)

        viewModel.postTitle.subscribe(onNext: { [weak self](text) in
            self?.setNeedsLayout()
            self?.layoutIfNeeded()

            self?.titleLabel.text = text
            if viewModel.titleExpendHeight <= 5 {
                self?.titleLabel.numberOfLines = 0
                self?.titleLabel.sizeToFit()
                viewModel.titleExpendHeight = self?.titleLabel.frame.maxY  ?? 44
            }

            if viewModel.titleFoldedHeight <= 5 {
                self?.titleLabel.numberOfLines = 3
                self?.titleLabel.sizeToFit()
                viewModel.titleFoldedHeight = self?.titleLabel.frame.maxY  ?? 44
                viewModel.reloadTitleSection.onNext(())
            }

        }).disposed(by: cellDisposeBag)

    }
}
