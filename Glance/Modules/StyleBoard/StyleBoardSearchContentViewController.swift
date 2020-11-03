//
//  StyleBoardSearchContentViewController.swift
//  Glance
//
//  Created by yanghai on 2020/10/26.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import ZLCollectionViewFlowLayout
import WMZPageController


class StyleBoardSearchContentViewController: CollectionViewController  {
    
    private lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<StyleBoardSearchSection> = configureDataSouce()
    

    override func makeUI() {
        super.makeUI()
                
        navigationBar.isHidden = true
        refreshComponent.accept(.footer)

        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.minimumLineSpacing = 20
        
        collectionView.collectionViewLayout = layout
        collectionView.register(nibWithCellClass: StyleBoardSearchCell.self)
        
        emptyDataSource.image.accept(R.image.icon_empty_search())
        emptyDataSource.subTitle.accept("No products found.Try other words of")
        emptyDataSource.buttonAttrTitle.accept(NSAttributedString(string: "Upload yourself", attributes: [.font: UIFont.titleFont(12), .foregroundColor :UIColor.primary()]))
        
        
    }
    
   
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? StyleBoardSearchContentViewModel else { return }
            
        let selection = collectionView.rx.modelSelected(StyleBoardSearchSectionItem.self).asObservable()
        let refresh = footerRefreshTrigger.mapToVoid()
        let upload = emptyDataSource.tap.asObservable()
        let input = StyleBoardSearchContentViewModel.Input(footerRefresh: refresh,
                                                           selection: selection,
                                                           upload: upload)
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)

    }
    
}
// MARK: - DataSouce
extension StyleBoardSearchContentViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<StyleBoardSearchSection> {
        return RxCollectionViewSectionedAnimatedDataSource<StyleBoardSearchSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: StyleBoardSearchCell.self)
            cell.bind(to: item.viewModel)
            return cell
        })
    }
    
}

extension StyleBoardSearchContentViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
        return UIEdgeInsets(top: inset, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2,sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset),itemInset: 15)
        return collectionView.ar_sizeForCell(withIdentifier: StyleBoardSearchCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) {[weak self] (cell) in
            if let item = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? StyleBoardSearchCell
                cell?.bind(to: item.viewModel)
            }
        }
        
    }
}
extension StyleBoardSearchContentViewController : WMZPageProtocol {
    
    func getMyScrollView() -> UIScrollView {
        return collectionView
    }
}
