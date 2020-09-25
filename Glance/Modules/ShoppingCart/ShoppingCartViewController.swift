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


class ShoppingCartViewController: TableViewController  {
    
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = "Shopping List"
        }).disposed(by: rx.disposeBag)
        
        tableView.register(nib: ShoppingCartCell.nib, withCellClass: ShoppingCartCell.self)
        tableView.rowHeight = 70 + 20
        
        
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
                
        
        output.openURL.drive(onNext: { [weak self] (url) in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                self?.exceptionError.onNext(.general("not open the url:\(url.absoluteString)"))
            }
        }).disposed(by: rx.disposeBag)

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
        
        output.detail
            .drive(onNext: { (item) in
                let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
                self.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.openURL.drive(onNext: { [weak self] (url) in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                self?.exceptionError.onNext(.general("not open the url:\(url.absoluteString)"))
            }
        }).disposed(by: rx.disposeBag)

        output.comparePrice.drive(onNext: { [weak self] (productId) in
            guard let self = self else { return }
            let selectStore = SelectStoreViewModel(provider: viewModel.provider, productId: productId)
            selectStore.action.bind(to: viewModel.selectStoreActions).disposed(by: self.rx.disposeBag)
            self.navigator.show(segue: .selectStore(viewModel: selectStore), sender: self,transition: .panel(style: .default))
        }).disposed(by: rx.disposeBag)

    }
    
}
