//
//  ReactionsViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReactionsViewController: TableViewController {
    
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var hahaLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var wowLabel: UILabel!
    
    override func makeUI() {
        super.makeUI()
        
        tableView.register(nib: ReactionsCell.nib, withCellClass: ReactionsCell.self)
        tableView.headRefreshControl = nil
        tableView.rowHeight = 70
        headView.removeFromSuperview()
        stackView.insertArrangedSubview(headView, at: 0)
        navigationTitle = "Reactions"
        headView.clipsToBounds = false
        
        lineView.layer.shadowOffset = CGSize(width: 0, height: 1)
        lineView.layer.shadowColor = UIColor(hex: 0x828282)!.withAlphaComponent(0.2).cgColor
        lineView.layer.shadowOpacity = 1
        lineView.clipsToBounds = false
//        lineView.layer.shadowPath = UIBezierPath.
//        lineView.addShadow(ofColor: <#T##UIColor#>, radius: <#T##CGFloat#>, offset: <#T##CGSize#>, opacity: <#T##Float#>)
        
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? ReactionsViewModel else { return }
        
        let input = ReactionsViewModel.Input(selection: tableView.rx.modelSelected(ReactionsCellViewModel.self).asObservable(),
                                             footerRefresh: footerRefreshTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: ReactionsCell.reuseIdentifier, cellType: ReactionsCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        output.haha.drive(hahaLabel.rx.text).disposed(by: rx.disposeBag)
        output.wow.drive(wowLabel.rx.text).disposed(by: rx.disposeBag)
        output.heart.drive(heartLabel.rx.text).disposed(by: rx.disposeBag)
        
        
    }
    
}

//func applyCurvedShadow(view: UIView) {
//    let size = view.bounds.size
//    let width = size.width
//    let height = size.height
//    let path = UIBezierPath()
//    path.move(to: CGPoint(x: width, y: 0))
//    path.addLine(to: CGPoint(x: width + 3, y: 0))
//    path.addLine(to: CGPoint(x: width + 3, y: height))
//    path.addLine(to: CGPoint(x:0, y: height))
//    path.close()
//    let layer = view.layer
//    layer.shadowPath = path.cgPath
//    layer.shadowColor = UIColor.black.cgColor
//    layer.shadowOpacity = 0.3
//    layer.shadowRadius = 3
//    layer.shadowOffset = CGSize(width: 3, height: 0)
//}
//
//
