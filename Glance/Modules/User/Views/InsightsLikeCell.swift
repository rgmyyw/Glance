//
//  InsightsLikeCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InsightsLikeCell: TableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var operationButton: UIButton!
    @IBOutlet weak var ighandleLabel: UILabel!

    override func makeUI() {
        super.makeUI()

        operationButton.setTitleColor(UIColor.white, for: .normal)
        operationButton.setTitleColor(UIColor.primary(), for: .selected)
        operationButton.borderColor = operationButton.titleColor(for: .selected)
        operationButton.cornerRadius = 4
    }

    override func bind<T>(to viewModel: T) where T: InsightsLikeCellViewModel {
        super.bind(to: viewModel)

        viewModel.userName.bind(to: userNameLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.userImageURL.bind(to: userImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.ighandle.bind(to: ighandleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.isFollow.bind(to: operationButton.rx.isSelected).disposed(by: cellDisposeBag)
        viewModel.buttonNormalTitle.bind(to: operationButton.rx.title(for: .normal)).disposed(by: cellDisposeBag)
        viewModel.buttonSelectedTitle.bind(to: operationButton.rx.title(for: .selected)).disposed(by: cellDisposeBag)
        viewModel.isFollow.map { $0 ?  1.0 : 0 }.bind(to: operationButton.rx.borderWidth).disposed(by: cellDisposeBag)
        viewModel.isFollow.map { $0 ? UIColor.clear : UIColor.primary()}.bind(to: operationButton.rx.backgroundColor).disposed(by: cellDisposeBag)
        operationButton.rx.tap.bind(to: viewModel.buttonTap).disposed(by: cellDisposeBag)
    }

}
