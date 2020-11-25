//
//  EmojiPopView.swift
//  Glance
//
//  Created by yanghai on 2020/7/7.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class ReactionPopManager {

    private let contentView = ReactionPopView.loadFromNib()
    static let share = ReactionPopManager()

    func show(in view: UIView?, anchorView: UIView?, selection: ((ReactionType) -> Void)?) {
        contentView.show(in: view, anchorView: anchorView, selection: selection)
    }

    func hidden() {
        contentView.hidden()
    }

}

class ReactionPopView: View {

    @IBOutlet weak var stackVaiew: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var items: [UIButton]!

    private weak var anchorView: UIView?
    private var selection: ((ReactionType) -> Void)?

    override func makeUI() {
        super.makeUI()

        items.tapGesture().subscribe(onNext: { [weak self](index) in
            if let type = ReactionType(rawValue: index + 1) {
                self?.selection?(type)
            }
            self?.hidden()
        }).disposed(by: rx.disposeBag)
    }

    func show(in view: UIView?, anchorView: UIView?, selection: ((ReactionType) -> Void)?) {

        guard let anchorView = anchorView else { return }

        let width: CGFloat = 150
        let height: CGFloat = 35

        let startPoint = CGPoint(x: anchorView.bounds.width, y: 0)
        let anchor = anchorView.convert(startPoint, to: view)

        let x = anchor.x - width
        var y =  anchor.y - height - 5

        let minY = view?.convert(CGPoint(x: x, y: y), to: UIApplication.shared.keyWindow).y ?? 0

        if minY < UIApplication.shared.statusBarFrame.height + 44 {
            y = anchorView.convert(CGPoint(x: anchorView.bounds.width, y: anchorView.bounds.height), to: view).y + 5
        }

        if let view = self.anchorView, view == anchorView {
            hidden()
            return
        } else {
            UIView.animate(withDuration: 0.5) { self.alpha = 0 }
            self.selection = selection
            self.anchorView = anchorView
        }

        if self.superview == nil {
            view?.addSubview(self)
        }

        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }

        snp.remakeConstraints { (make) in
            make.left.equalTo(x)
            make.top.equalTo(y)
            make.size.equalTo(CGSize(width: width, height: height))
        }
        setNeedsLayout()
        layoutIfNeeded()
    }

    func hidden() {
        self.selection = nil
        self.anchorView = nil
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }, completion: { (_) in
            self.removeFromSuperview()
        })
    }

}
