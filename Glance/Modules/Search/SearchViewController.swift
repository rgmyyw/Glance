//
//  SearchViewController.swift
//  Glance
//
//  Created by yanghai on 2020/9/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WMZPageController

class SearchViewController: TableViewController , UITextFieldDelegate  {
    
    private lazy var customNavigationBar : SearchNavigationBar = SearchNavigationBar.loadFromNib(height: 44,width: self.view.width)

    let textFieldReturn = PublishSubject<Void>()
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.addSubview(customNavigationBar)

        tableView.register(nib: SearchCell.nib, withCellClass: SearchCell.self)
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
        tableView.rowHeight = 44
        
        customNavigationBar.textField.delegate = self
        
        rx.viewDidAppear.mapToVoid()
            .bind(to: customNavigationBar.textField.rx.becomeFirstResponder)
            .disposed(by: rx.disposeBag)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SearchViewModel else { return }
        
        let input = SearchViewModel.Input(cancel: customNavigationBar.cancelButton
            .rx.tap.asObservable(),selection: tableView.rx.modelSelected(SearchCellViewModel.self).asObservable(),
                                                headerRefresh : headerRefreshTrigger.asObservable(),
                                                footerRefresh: footerRefreshTrigger.asObservable(),
                                                textFieldReturn: textFieldReturn.asObservable())
        let output = viewModel.transform(input: input)

        (customNavigationBar.textField.rx.textInput <-> viewModel.text).disposed(by: rx.disposeBag)
        output.items
            .drive(tableView.rx.items(cellIdentifier: SearchCell.reuseIdentifier, cellType: SearchCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        
        output.search.drive(onNext: { [weak self](text) in
            let result = SearchResultViewModel(provider: viewModel.provider, text: text)
            self?.navigator.show(segue: .searchResult(viewModel: result), sender: self)
        }).disposed(by: rx.disposeBag)
        
        output.close.drive(onNext: { [weak self]() in
            self?.navigator.dismiss(sender: self)
        }).disposed(by: rx.disposeBag)

        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldReturn.onNext(())
        return true
    }
}
