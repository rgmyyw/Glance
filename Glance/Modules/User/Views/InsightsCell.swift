//
//  InsightsCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InsightsCell: TableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reachCountLabel: UILabel!
    @IBOutlet weak var interactionsCountLabel: UILabel!
    @IBOutlet weak var bgView: UIView!

    override func makeUI() {
        super.makeUI()

        contentView.clipsToBounds = false
        clipsToBounds = false

        let shadowOffset = CGSize(width: 0, height: 1)
        let color = UIColor(hex: 0x828282)!.withAlphaComponent(0.2)
        let opacity: CGFloat = 1
        bgView.shadow(cornerRadius: 8, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 5)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func bind<T>(to viewModel: T) where T: InsightsCellViewModel {
        super.bind(to: viewModel)

        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.imageURL.bind(to: iconImageView.rx.imageURL).disposed(by: cellDisposeBag)
        viewModel.time.bind(to: timeLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.reachCount.bind(to: reachCountLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.interactionsCount.bind(to: interactionsCountLabel.rx.text).disposed(by: cellDisposeBag)
    }
}
