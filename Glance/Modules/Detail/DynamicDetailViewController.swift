//
//  DynamicDetailViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ZLCollectionViewFlowLayout
import RxSwift
import RxCocoa



class DynamicDetailViewController: CollectionViewController {

    private lazy var customNavigationBar : DynamicDetailNavigationBar = DynamicDetailNavigationBar.loadFromNib(height: 44,width: self.view.width)
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.addSubview(customNavigationBar)
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        //collectionView.register(nibWithCellClass: RecommendedGoodsCell.self)
        
        collectionView.register(nib: DynamicDetailHeadReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: DynamicDetailHeadReusableView.self)
        
        
//        collectionView.register(nib: HomeBannerReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: HomeBannerReusableView.self)
//        collectionView.register(nib: HomeActivityReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: HomeActivityReusableView.self)
//        collectionView.register(nib: HomeFeatureCategoryReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: HomeFeatureCategoryReusableView.self)

    }
    
}

extension DynamicDetailViewController : ZLCollectionViewBaseFlowLayoutDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
//        
//        return ColumnLayout
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
//        return 2
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        switch dataSouce.sectionModels[section] {
//        case .banner:
//            return CGSize(width: collectionView.width, height: 160)
//        case .activity:
//            return CGSize(width: collectionView.width, height: 115 + inset)
//        case .category:
//            return CGSize(width: collectionView.width, height: 230 + inset)
//        case.recommend:
//            return CGSize(width: collectionView.width, height: 40)
//        }
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        switch dataSouce.sectionModels[section] {
//        case .banner:
//            return UIEdgeInsets(top: 8, left: inset, bottom: inset, right: inset)
//        case .recommend:
//            return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
//        default:
//            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
//        }
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let collectionView = collectionView as! CollectionView
//        return collectionView.ar_sizeForCell(withIdentifier: RecommendedGoodsCell.reuseIdentifier, indexPath: indexPath, fixedWidth: collectionView.itemWidth(forItemsPerRow: 2)) {[weak self] (cell) in
//            if case let .recommend(viewModel) = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
//                let cell = cell  as? RecommendedGoodsCell
//                cell?.bind(to: viewModel)
//                cell?.setNeedsLayout()
//                cell?.needsUpdateConstraints()
//            }
//        }
//        
//    }
}


