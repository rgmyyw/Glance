//
//  ShoppingCartViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ShoppingCartViewController: TableViewController {
    
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = "Shopping List"
        }).disposed(by: rx.disposeBag)
        
        tableView.register(nib: ShoppingCartCell.nib, withCellClass: ShoppingCartCell.self)
        tableView.rowHeight = 75 + 20
        
        
    }
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? ShoppingCartViewModel else { return }
        
        
        let refresh = Observable.just(()).merge(with: headerRefreshTrigger.asObservable())
        let input = ShoppingCartViewModel.Input(headerRefresh: refresh,
                                                footerRefresh: footerRefreshTrigger.asObservable(),
                                                selection: tableView.rx.modelSelected(ShoppingCartCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: ShoppingCartCell.reuseIdentifier, cellType: ShoppingCartCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
                

        output.delete.subscribe(onNext: { [weak self]cellViewModel in
            guard let self = self else { return }
            Alert.showAlert(with: "Remove product?",
                         message: "You’reabout to remove this product.",
                         optionTitles: "REMOVE",
                         cancel: "CANCEL")
            .subscribe(onNext: { (item) in
                if item == 0 {viewModel.confirmDelete.onNext(cellViewModel) }
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        output.comparePrice
            .subscribe(onNext: { [weak self](item) in
                let viewModel = ComparePriceViewModel(provider: viewModel.provider)
                self?.navigator.show(segue: .comparePrice(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
        
        

    }
    
}
