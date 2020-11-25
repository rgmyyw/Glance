//
//  InsightsDetailViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class InsightsDetailViewController: ViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reachedCountLabel: UILabel!
    @IBOutlet weak var interactionsCountLabel: UILabel!
    @IBOutlet weak var saveCountLabel: UILabel!
    @IBOutlet weak var recommendsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var sharesCountLabel: UILabel!
    @IBOutlet weak var reactionsCountLabel: UILabel!
    @IBOutlet weak var recommendTagImageView: UIImageView!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet var cells: [UIStackView]!

    override func makeUI() {
        super.makeUI()
        stackView.addArrangedSubview(scrollView)
        cells.forEach { $0.isHidden = true }
    }

    override func bindViewModel() {
        super.bindViewModel()

        guard let viewModel = viewModel as? InsightsDetailViewModel else { return }

        let input = InsightsDetailViewModel.Input(selection: cells.tapGesture(), previewPost: previewButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        output.imageURL.drive(imageView.rx.imageURL).disposed(by: rx.disposeBag)
        output.title.drive(titleLabel.rx.text).disposed(by: rx.disposeBag)
        output.time.drive(timeLabel.rx.text).disposed(by: rx.disposeBag)
        output.reachedCount.drive(reachedCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.interactionsCount.drive(interactionsCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.saveCount.drive(saveCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.recommendsCount.drive(recommendsCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.likesCount.drive(likesCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.sharesCount.drive(sharesCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.reactionsCount.drive(reactionsCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.previewButtonTitle.drive(previewButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.navigationTitle.drive(navigationBar.rx.title).disposed(by: rx.disposeBag)
        output.reaction.subscribe(onNext: {[weak self] (item) in
            let viewModel = ReactionsViewModel(provider: viewModel.provider, item: item)
            self?.navigator.show(segue: .reactions(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.likes.subscribe(onNext: {[weak self] (item) in
            let viewModel = InsightsRelationViewModel(provider: viewModel.provider, item: item, type: .liked)
            self?.navigator.show(segue: .insightsRelation(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.recommend.subscribe(onNext: {[weak self] (item) in
            let viewModel = InsightsRelationViewModel(provider: viewModel.provider, item: item, type: .recommend)
            self?.navigator.show(segue: .insightsRelation(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.available.subscribe(onNext: {[weak self] items in
            items.forEach { self?.cells[$0].isHidden = false }
        }).disposed(by: rx.disposeBag)

        output.previewPost.drive(onNext: {[weak self] (item) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
            self?.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
    }

}
