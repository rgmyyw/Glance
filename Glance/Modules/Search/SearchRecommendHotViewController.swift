//
//  SearchRecommendHotViewController.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import ZLCollectionViewFlowLayout
import UICollectionView_ARDynamicHeightLayoutCell
import Popover
import WMZPageController

class SearchRecommendHotViewController: TableViewController  {
    
    private lazy var dataSouce : RxTableViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotCellViewModel>> = configureDataSouce()
    private lazy var filterView : SearchRecommendHotFilterView = SearchRecommendHotFilterView.loadFromNib(height: 60, width: UIScreen.width)

    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.isHidden = true
        stackView.insertArrangedSubview(filterView, at: 0)
        tableView.register(nibWithCellClass: SearchRecommendHotCell.self)
        tableView.rowHeight = 170
        //tableView.headRefreshControl = nil
        
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? SearchRecommendHotViewModel else { return }
        
        
        let refresh = Observable.just(()).merge(with: headerRefreshTrigger)
        let input = SearchRecommendHotViewModel.Input(headerRefresh: refresh,
                                                      footerRefresh: footerRefreshTrigger.mapToVoid(),
                                                      filter: filterView.collectionView.rx.modelSelected(SearchRecommendHotFilterCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)

        output.items.drive(tableView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.themeDetail
            .drive(onNext: { [weak self](themeId) in
                let viewModel = SearchThemeViewModel(provider: viewModel.provider, themeId: themeId)
                self?.navigator.show(segue: .searchTheme(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        output.filter.bind(to: filterView.items).disposed(by: rx.disposeBag)

        
    }
}
// MARK: - DataSouce
extension SearchRecommendHotViewController {
    
    fileprivate func configureDataSouce() -> RxTableViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotCellViewModel>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotCellViewModel>>(configureCell : { (dataSouce, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchRecommendHotCell.self)
            cell.bind(to: item)
            return cell
        })
    }
    
}


extension SearchRecommendHotViewController : WMZPageProtocol {
    
    func getMyScrollView() -> UIScrollView {
        return tableView
    }
}
