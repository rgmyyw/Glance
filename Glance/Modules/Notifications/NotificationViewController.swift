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
        
        
    }
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? NotificationViewModel else { return }
        
        let refresh = Observable.just(()).merge(with: headerRefreshTrigger.asObservable())
        let input = NotificationViewModel.Input(headerRefresh: refresh,
                                                footerRefresh: footerRefreshTrigger.asObservable(),
                                                selection: tableView.rx.modelSelected(NotificationCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: NotificationCell.reuseIdentifier, cellType: NotificationCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        
        
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.noMoreData.bind(to: noMoreData).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)

    }
    
}
