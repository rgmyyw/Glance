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
import RxDataSources
import SwipeCellKit


class NotificationViewController: TableViewController {
    
    private lazy var dataSouce : RxTableViewSectionedAnimatedDataSource<NotificationSection> = configureDataSouce()
    
    lazy var clearButton : UIButton = {
        let button = UIButton()
        button.setTitle("All tags read", for: .normal)
        button.setTitleColor(UIColor.text(), for: .normal)
        button.titleLabel?.font = UIFont.titleFont(14)
        return button
    }()
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = "Notifications"
        }).disposed(by: rx.disposeBag)
        
        
        navigationBar.rightBarButtonItem = clearButton
        
        tableView.register(nib: NotificationCell.nib, withCellClass: NotificationCell.self)
        tableView.register(nib: NotificationFollowingCell.nib, withCellClass: NotificationFollowingCell.self)
        tableView.register(nib: NotificationLikedCell.nib, withCellClass: NotificationLikedCell.self)
        tableView.register(nib: NotificationRecommendedCell.nib, withCellClass: NotificationRecommendedCell.self)
        tableView.register(nib: NotificationReactionCell.nib, withCellClass: NotificationReactionCell.self)
        tableView.register(nib: NotificationMightLikeCell.nib, withCellClass: NotificationMightLikeCell.self)
        tableView.register(nib: NotificationSystemCell.nib, withCellClass: NotificationSystemCell.self)
        tableView.register(nib: NotificationThemeCell.nib, withCellClass: NotificationThemeCell.self)
        
        emptyDataSource.image.accept(R.image.icon_empty_notifications())
        emptyDataSource.title.accept("No Notifications")
        emptyDataSource.subTitle.accept("You can have a look around first")
        
    }
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? NotificationViewModel else { return }
        let clear = clearButton.rx.tap.asObservable()
        let selection = tableView.rx.modelSelected(NotificationSectionItem.self).asObservable()
        
        let input = NotificationViewModel.Input(headerRefresh: headerRefreshTrigger.asObservable(),
                                                footerRefresh: footerRefreshTrigger.asObservable(),
                                                selection: selection,
                                                clear: clear)
        let output = viewModel.transform(input: input)
        
        output.items.drive(tableView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        
        output.userDetail.drive(onNext: { [weak self](user) in
            let viewModel = UserDetailViewModel(provider: viewModel.provider, otherUser: user)
            self?.navigator.show(segue: .userDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
        output.themeDetail.drive(onNext: { [weak self](themeId) in
            let viewModel = SearchThemeViewModel(provider: viewModel.provider, themeId: themeId)
            self?.navigator.show(segue: .searchTheme(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

    }
    
}

extension NotificationViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
                
        let delete = SwipeAction(style: .default, title: "Delete", handler: { [weak self] _, indexPath in
            self?.dataSouce[indexPath.section].items[indexPath.row]
                .viewModel.delete.onNext(())
        })
        delete.hidesWhenSelected = true
        delete.font = UIFont.titleBoldFont(14)
        delete.backgroundColor = UIColor.primary()
        delete.textColor = UIColor.white
        
        return [delete]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = orientation == .left ? .selection : nil
        options.transitionStyle = .border
        options.minimumButtonWidth = 75
        options.buttonSpacing = 4
        options.backgroundColor = .clear
        return options
    }
    
    
    fileprivate func configureDataSouce() -> RxTableViewSectionedAnimatedDataSource<NotificationSection> {
        return RxTableViewSectionedAnimatedDataSource<NotificationSection>(configureCell : {[weak self] (dataSouce, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as! NotificationCell
            cell.bind(to: item.viewModel)
            cell.delegate = self
            return cell
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch dataSouce[indexPath.section].items[indexPath.row]{
        default:
            return 75
        }
    }
    
}
