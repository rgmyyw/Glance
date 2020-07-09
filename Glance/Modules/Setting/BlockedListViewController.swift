//
//  BlockedListViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BlockedListViewController: TableViewController {
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = "Blocked List"
        }).disposed(by: rx.disposeBag)
        
        tableView.register(nib: BlockedCell.nib, withCellClass: BlockedCell.self)
        tableView.headRefreshControl = nil
        tableView.rowHeight = 70
        
        
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? BlockedListViewModel else { return }
        
        let input = BlockedListViewModel.Input(selection: tableView.rx.modelSelected(BlockedCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: BlockedCell.reuseIdentifier, cellType: BlockedCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        
        output.saved.delay(RxTimeInterval.seconds(1))
            .drive(onNext: { [weak self] () in
                self?.navigator.pop(sender: self)
            }).disposed(by: rx.disposeBag)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.textColor = UIColor(hex: 0x999999)
        label.font = UIFont.titleFont(12)
        label.numberOfLines = 0
        label.text = "Users will not be notified when you block them.Blocked users will not be able to message you, see any of your posts, nor find you on the Search bar, even if they are your followers."
        view.addSubview(label)
        view.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.width.equalTo(tableView.width)
        }
        label.snp.makeConstraints { (make) in
            make.top.left.equalTo(20)
            make.right.equalTo(view.snp.right).offset(-20)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
}
