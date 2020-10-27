//
//  NotificationViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NotificationViewController: TableViewController {
    
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = "Notifications"
        }).disposed(by: rx.disposeBag)
        
        tableView.register(nib: NotificationCell.nib, withCellClass: NotificationCell.self)
        tableView.rowHeight = 75 + 20
        
        emptyDataSource.image.accept(R.image.icon_empty_notifications())
        emptyDataSource.title.accept("No Notifications")
        emptyDataSource.subTitle.accept("You can have a look around first")
        
    }
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? NotificationViewModel else { return }
        
        let input = NotificationViewModel.Input(headerRefresh: headerRefreshTrigger.asObservable(),
                                                footerRefresh: footerRefreshTrigger.asObservable(),
                                                selection: tableView.rx.modelSelected(NotificationCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: NotificationCell.reuseIdentifier, cellType: NotificationCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        
        
        

    }
    
}
