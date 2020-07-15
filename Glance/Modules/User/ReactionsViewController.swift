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
    
    override func makeUI() {
        super.makeUI()
        
        tableView.register(nib: ReactionsCell.nib, withCellClass: ReactionsCell.self)
        tableView.headRefreshControl = nil
        tableView.rowHeight = 70
        headView.removeFromSuperview()
        stackView.insertArrangedSubview(headView, at: 0)
        navigationTitle = "Reactions"
        lineView.shadow(cornerRadius: 0, shadowOpacity: 1,
                        shadowColor: UIColor(hex: 0x828282)!.withAlphaComponent(0.2),
                        shadowOffset: CGSize(width: 0, height: 1), shadowRadius: 5)
        
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
        
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)

    }
    
}

