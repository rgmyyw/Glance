//
//  VisualSearchResultViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/30.
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

class VisualSearchResultViewController: CollectionViewController  {
    
    private lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<VisualSearchResultSection> = configureDataSouce()
    
    override func makeUI() {
        super.makeUI()
        
            
        // titleLabel
        let navigationTitleLabel = UILabel()
        navigationTitleLabel.text = "Visual Search"
        navigationTitleLabel.font = UIFont.titleBoldFont(18)
        navigationTitleLabel.textColor = UIColor.text()
        navigationTitleLabel.sizeToFit()
        navigationBar.bottomLineView.isHidden = false
        navigationBar.addSubview(navigationTitleLabel)
        navigationTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(navigationBar.snp.centerX)
            make.top.equalTo(navigationBar.snp.top).offset(10)
        }
        
        // searchButton
        let searchButton = UIButton()
        searchButton.setImage(R.image.icon_navigation_search(), for: .normal)
        navigationBar.rightBarButtonItem = searchButton
        
        // 返回按钮
        backButton.setImage(R.image.icon_navigation_close(), for: .normal)
        
        
        let titleBgView = View(height: 60)
        let titleLabel = UILabel()
        titleLabel.text = "Suggested Products"
        titleLabel.font = UIFont.titleBoldFont(15)
        titleLabel.textColor = UIColor.text()
        titleLabel.sizeToFit()
        titleBgView.addSubview(titleLabel)
        stackView.insertArrangedSubview(titleBgView, at: 0)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(20)
        }
        
        
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = 20
        
        
        collectionView.collectionViewLayout = layout
        collectionView.register(nibWithCellClass: VisualSearchResultCell.self)
        exceptionToastPosition = .center
        refreshComponent.accept(.footer)
    }
    
    override func navigationBack() {
        self.navigator.dismiss(sender: self, animated: true)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? VisualSearchResultViewModel else { return }

        let input = VisualSearchResultViewModel.Input(footerRefresh: footerRefreshTrigger.mapToVoid(),
                                                      selection: collectionView.rx.modelSelected(VisualSearchResultSectionItem.self).asObservable(),
                                                      search: (navigationBar.rightBarButtonItem as! UIButton).rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
                
        output.search.subscribe(onNext: { [weak self](box, image) in
            guard let self = self else { return }
            let search = VisualSearchProductViewModel(provider: viewModel.provider, image: image, box: box)
            search.selected.bind(to: viewModel.searchSelection).disposed(by: self.rx.disposeBag)
            self.navigator.show(segue: .visualSearchProduct(viewModel: search), sender: self)
        }).disposed(by: rx.disposeBag)
    }
}
// MARK: - DataSouce
extension VisualSearchResultViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<VisualSearchResultSection> {
        return RxCollectionViewSectionedAnimatedDataSource<VisualSearchResultSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: VisualSearchResultCell.self)
            cell.bind(to: item.viewModel)
            return cell
        })
    }
    
}

extension VisualSearchResultViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2,sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset),itemInset: 15)
        return collectionView.ar_sizeForCell(withIdentifier: VisualSearchResultCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) {[weak self] (cell) in
            if let item = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? VisualSearchResultCell
                cell?.bind(to: item.viewModel)
            }
        }
        
    }
}
