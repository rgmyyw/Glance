//
//  PostsDetailMoreReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/11/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostsDetailMoreReusableView: CollectionReusableView {

    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!

    override func makeUI() {
        super.makeUI()
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    override func bind<T>(to viewModel: T) where T: PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)

        let showMore = moreButton.rx.tap.mapToVoid().merge(with: arrowButton.rx.tap.mapToVoid())
        showMore.map { !viewModel.folded.value}.bind(to: viewModel.folded).disposed(by: cellDisposeBag)
        showMore.bind(to: viewModel.reloadTitleSection).disposed(by: cellDisposeBag)
        viewModel.folded.map { !$0}.bind(to: arrowButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.folded.map { !$0}.bind(to: moreButton.rx.isSelected).disposed(by: cellDisposeBag)
    }
}
