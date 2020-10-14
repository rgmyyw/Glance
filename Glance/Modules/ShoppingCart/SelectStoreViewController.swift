//
//  SelectStoreViewController.swift
//  Glance
//
//  Created by yanghai on 2020/9/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import UIKit
import RxSwift
import RxCocoa
import FloatingPanel

class SelectStoreViewController: TableViewController, FloatingPanelControllerDelegate {

    override func makeUI() {
        super.makeUI()
        
        viewDidLoadBeginRefresh = false
        automaticallyAdjustsLeftBarButtonItem = false
        refreshComponent.accept(.none)
        navigationBar.rightBarButtonItem = closeButton
        
        tableView.register(nib: SelectStoreCell.nib, withCellClass: SelectStoreCell.self)
        tableView.rowHeight = 90
        navigationBar.title = "Select Store"
        navigationBar.snp.updateConstraints { (make) in
            make.height.equalTo(58)
        }
    }
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SelectStoreViewModel else { return }
        
        let input = SelectStoreViewModel.Input(headerRefresh: Observable.just(()),
                                                footerRefresh: footerRefreshTrigger.asObservable(),
                                                selection: tableView.rx.modelSelected(SelectStoreCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.close.drive(onNext: { [weak self]() in
            self?.navigator.dismiss(sender: self)
        }).disposed(by: rx.disposeBag)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: SelectStoreCell.reuseIdentifier, cellType: SelectStoreCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        

    }
    
}
