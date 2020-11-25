//
//  NotificationCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwipeCellKit

class NoticeCell: SwipeTableViewCell {

    public var cellDisposeBag: DisposeBag!
    public let bgView: UIView = UIView()
    public let lineView: UIView = UIView()
    public let stackView: StackView = StackView()

    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()

    }

    func updateUI() {
        setNeedsDisplay()
    }

    func makeUI() {
        lineView.backgroundColor = UIColor(hex: 0xF5F5F5)
        contentView.addSubview(bgView)
        bgView.addSubview(stackView)
        bgView.addSubview(lineView)

        bgView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.equalTo(20)
            make.right.equalTo(contentView.snp.right).offset(-20)
        }
        stackView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(bgView)
            make.bottom.equalTo(lineView.snp.top)
        }

        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalTo(bgView)
        }

        layer.masksToBounds = true
        selectionStyle = .none
        backgroundColor = .clear
        updateUI()

    }

    func bind<T>(to viewModel: T) where T: NoticeCellViewModel {
        cellDisposeBag = DisposeBag()
    }

}
