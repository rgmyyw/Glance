//
//  NoticeViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NoticeViewController: TableViewController {
    
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = "Notifications"
        }).disposed(by: rx.disposeBag)
        
        tableView.register(nib: NoticeCell.nib, withCellClass: NoticeCell.self)
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
        tableView.rowHeight = 75 + 20
        
        
    }
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? NoticeViewModel else { return }
        
        let input = NoticeViewModel.Input(selection: tableView.rx.modelSelected(NoticeCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: NoticeCell.reuseIdentifier, cellType: NoticeCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        
        output.saved.delay(RxTimeInterval.seconds(1))
            .drive(onNext: { [weak self] () in
                self?.navigator.pop(sender: self)
            }).disposed(by: rx.disposeBag)
    }
    
}
