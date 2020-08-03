//
//  ComparePriceViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit

class ComparePriceViewController: TableViewController, SwipeTableViewCellDelegate  {
    
    
    
    override func makeUI() {
        super.makeUI()
        
    
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = "237 offers"
        }).disposed(by: rx.disposeBag)
        
        tableView.register(nib: ComparePriceCell.nib, withCellClass: ComparePriceCell.self)
        tableView.rowHeight = 60
        tableView.delegate = self
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? ComparePriceViewModel else { return }
        
        
        let refresh = Observable.just(()).merge(with: headerRefreshTrigger.asObservable())
        let input = ComparePriceViewModel.Input(headerRefresh: refresh,
                                                footerRefresh: footerRefreshTrigger.asObservable(),
                                                selection: tableView.rx.modelSelected(ShoppingCartCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: ComparePriceCell.reuseIdentifier, cellType: ComparePriceCell.self)) { tableView, viewModel, cell in
                cell.delegate = self
//                cell.bind(to: viewModel)
                
        }.disposed(by: rx.disposeBag)
                
        viewModel.message.bind(to: message).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.hasData.bind(to: hasData).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)

    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = .border
        options.buttonSpacing = 4
        options.backgroundColor = .clear
        
        return options
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let arrow = SwipeAction(style: .default, title: nil) { action, indexPath in }
        arrow.image = R.image.icon_cell_arrow_left()
        arrow.backgroundColor = .clear
        let delete = SwipeAction(style: .default, title: "Add to\n Shopping List") {[weak self] action, indexPath in
            action.fulfill(with: .reset)
            self?.message.onNext(.init("Successtully added to your shopping list"))
        }
        delete.font = UIFont.titleBoldFont(12)
        delete.textColor = .white
        delete.backgroundColor = .clear
        delete.transitionDelegate = ScaleTransition.default
        delete.fulfill(with: .reset)
        return [delete,arrow]
    }


  
    
}
