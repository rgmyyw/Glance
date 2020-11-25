//
//  UsersViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/13.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WMZPageController

class UsersViewController: TableViewController {

    override func makeUI() {
        super.makeUI()

        viewDidLoadBeginRefresh = false
        tableView.register(nib: UsersCell.nib, withCellClass: UsersCell.self)
        tableView.rowHeight = 70
    }

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? UsersViewModel else { return }

        let refresh = headerRefreshTrigger.asObservable().merge(with: rx.viewDidAppear.mapToVoid())
        let input = UsersViewModel.Input(selection: tableView.rx.modelSelected(UsersCellViewModel.self).asObservable(),
                                                headerRefresh: refresh,
                                                footerRefresh: footerRefreshTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.items
            .drive(tableView.rx.items(cellIdentifier: UsersCell.reuseIdentifier, cellType: UsersCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)

        output.userDetail.drive(onNext: { [weak self](user) in
            let viewModel = UserDetailViewModel(provider: viewModel.provider, otherUser: user)
            self?.navigator.show(segue: .userDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.navigationTitle.drive(navigationBar.rx.title).disposed(by: rx.disposeBag)
        output.navigationTitle.map { $0.isEmpty}.drive(navigationBar.rx.isHidden).disposed(by: rx.disposeBag)

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let tableViewHeadHidden = (viewModel as? UsersViewModel)?.tableViewHeadHidden.value,
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
        return (viewModel as? UsersViewModel)?.tableViewHeadHidden.value ?? true ? 0.1 : 80
    }

}

extension UsersViewController: WMZPageProtocol {

    func getMyTableView() -> UITableView {
        return tableView
    }
}
