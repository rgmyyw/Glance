//
//  InsightsRelationViewController.swift
//  Glance
//
//  Created by yanghai on 2020/8/24.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WMZPageController

class InsightsRelationViewController: TableViewController {
    
    override func makeUI() {
        super.makeUI()
        
        tableView.register(nib: InsightsLikeCell.nib, withCellClass: InsightsLikeCell.self)
        tableView.rowHeight = 70
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? InsightsRelationViewModel else { return }
        
        let input = InsightsRelationViewModel.Input(selection: tableView.rx.modelSelected(InsightsLikeCellViewModel.self).asObservable(), headerRefresh: headerRefreshTrigger.asObservable(),footerRefresh: footerRefreshTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.items
            .drive(tableView.rx.items(cellIdentifier: InsightsLikeCell.reuseIdentifier, cellType: InsightsLikeCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)

        output.navigationTitle.drive(navigationBar.rx.title).disposed(by: rx.disposeBag)
        output.navigationTitle.map { $0.isEmpty}.drive(navigationBar.rx.isHidden).disposed(by: rx.disposeBag)
        

    }
}
