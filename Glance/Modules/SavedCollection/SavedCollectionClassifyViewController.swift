//
//  SavedCollectionViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class SavedCollectionClassifyViewController: ViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var items: [UIImageView]!
    @IBOutlet weak var totalLabel: UILabel!

    override func makeUI() {
        super.makeUI()
        stackView.addArrangedSubview(scrollView)
        navigationTitle = "Saved Collection"
    }

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SavedCollectionClassifyViewModel else { return }

        let input = SavedCollectionClassifyViewModel.Input(refresh: rx.viewWillAppear.mapToVoid())
        let output = viewModel.transform(input: input)
        output.total.drive(totalLabel.rx.text).disposed(by: rx.disposeBag)
        output.images.drive(onNext: { [weak self] images in
            guard let self = self else { return }
            images.enumerated().forEach { (index, item) in
                item.bind(to: self.items[index].rx.imageURL).disposed(by: self.rx.disposeBag)
            }
        }).disposed(by: rx.disposeBag)

        items.tapGesture()
            .subscribe(onNext: { [weak self](_) in
                let viewModel = SavedCollectionViewModel(provider: viewModel.provider)
                self?.navigator.show(segue: .savedCollection(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

    }

}
