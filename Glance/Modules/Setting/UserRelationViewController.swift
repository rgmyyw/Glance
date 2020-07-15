//
//  UserRelationViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/13.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WMZPageController


class UserRelationViewController: TableViewController {
    
    override func makeUI() {
        super.makeUI()
        
        tableView.register(nib: UserRelationCell.nib, withCellClass: UserRelationCell.self)
        tableView.headRefreshControl = nil
        tableView.rowHeight = 70
        
        
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? UserRelationViewModel else { return }
        
        let input = UserRelationViewModel.Input(selection: tableView.rx.modelSelected(UserRelationCellViewModel.self).asObservable(),
                                                footerRefresh: footerRefreshTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.items
            .drive(tableView.rx.items(cellIdentifier: UserRelationCell.reuseIdentifier, cellType: UserRelationCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)

        output.navigationTitle.drive(navigationBar.rx.title).disposed(by: rx.disposeBag)
        output.navigationTitle.map { $0.isEmpty}.drive(navigationBar.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)

    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let tableViewHeadHidden = (viewModel as? UserRelationViewModel)?.tableViewHeadHidden.value,
            tableViewHeadHidden == false  else {
                return nil
        }

        let view = UIView()
        let label = UILabel()
        label.textColor = UIColor(hex: 0x999999)
        label.font = UIFont.titleFont(12)
        label.numberOfLines = 0
        label.text = "Users will not be notified when you block them.Blocked users will not be able to message you, see any of your posts, nor find you on the Search bar, even if they are your followers."
        view.addSubview(label)
        label.sizeToFit()

        label.snp.makeConstraints { (make) in
            make.top.left.equalTo(20)
            make.right.equalTo(view.snp.right).offset(-20)
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (viewModel as? UserRelationViewModel)?.tableViewHeadHidden.value ?? false ? 0 : 80
    }


}

extension UserRelationViewController : WMZPageProtocol {
    
    func getMyTableView() -> UITableView {
        return tableView
    }
}

