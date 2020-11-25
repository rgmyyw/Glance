//
//  PostProductTagCell.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostProductTagCell: CollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func bind<T>(to viewModel: T) where T: PostProductTagCellViewModel {
        super.bind(to: viewModel)

        viewModel.title.bind(to: label.rx.text).disposed(by: cellDisposeBag)

        let sytle = Observable.combineLatest(viewModel.selected, viewModel.style)
        sytle.map { $0 ? $1?.selectedTitleColor : $1?.normalTitleColor}.bind(to: label.rx.textColor).disposed(by: cellDisposeBag)
        sytle.map { $0 ? $1?.selectedBackgroundColor : $1?.normalBackgroundColor}.bind(to: bgView.rx.backgroundColor).disposed(by: cellDisposeBag)
        sytle.map { $0 ? $1?.actionButtonTitleSelectedColor : $1?.actionButtonTitleNormalColor}.bind(to: actionButton.rx.titleColor(for: .normal)).disposed(by: cellDisposeBag)

        let buttonTitle = sytle.map { $0 ? $1?.actionButtonSelectedTitle : $1?.actionButtonNormalTitle }
        buttonTitle.filterNil().map { $0.isEmpty  }.bind(to: actionButton.rx.isHidden).disposed(by: cellDisposeBag)
        buttonTitle.bind(to: actionButton.rx.title(for: .normal)).disposed(by: cellDisposeBag)

        Observable.combineLatest(bgView.rx.tap().merge(with: actionButton.rx.tap.asObservable()), viewModel.style.filterNil())
            .map { (_, style) -> PostProductTagStyle.PostProductTagStyleAction in
            return style == .custom ? PostProductTagStyle.PostProductTagStyleAction.delete : PostProductTagStyle.PostProductTagStyleAction.state(!viewModel.selected.value)
        }.bind(to: viewModel.action).disposed(by: cellDisposeBag)
    }

}
