//
//  InsightsChildViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import WMZPageController

class InsightsChildViewController: TableViewController {
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.isHidden = true
        tableView.headRefreshControl = nil
        tableView.register(nibWithCellClass: InsightsCell.self)
        tableView.rowHeight = 95
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? InsightsChildViewModel else { return }
        
        let refresh = Observable<Void>.merge(Observable.just(()), headerRefreshTrigger)
        let input = InsightsChildViewModel.Input(headerRefresh: refresh,
                                        footerRefresh: footerRefreshTrigger.mapToVoid(),
                                        selection: tableView.rx.modelSelected(InsightsCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        output.items.drive(tableView.rx.items(cellIdentifier: InsightsCell.reuseIdentifier, cellType: InsightsCell.self)) { tableView, item, cell in
            cell.bind(to: item)
        }.disposed(by: rx.disposeBag)

        
        

    }

}
