//
//  SearchRecommendHotFilterView.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ZLCollectionViewFlowLayout
import RxSwift
import RxCocoa
import RxDataSources

class SearchRecommendHotFilterView: View {

    lazy var dataSouce : RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotFilterCellViewModel>> = configureDataSouce()

    @IBOutlet weak var collectionView: UICollectionView!
    
    let items = BehaviorRelay<[SectionModel<Void,SearchRecommendHotFilterCellViewModel>]>(value:[])
        
    override func makeUI() {
        super.makeUI()
        
        let layout = ZLCollectionViewHorzontalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(nibWithCellClass: SearchRecommendHotFilterCell.self)
        items.asDriver().drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        items.asDriver().delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        
    }
  
}

// MARK: - DataSouce
extension SearchRecommendHotFilterView {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotFilterCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotFilterCellViewModel>>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SearchRecommendHotFilterCell.self)
            cell.bind(to: item)
            return cell
        })
    }
    
}

extension SearchRecommendHotFilterView : ZLCollectionViewBaseFlowLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let viewModel =  dataSouce[indexPath.section].items[indexPath.item]
        return collectionView.ar_sizeForCell(withIdentifier: SearchRecommendHotFilterCell.reuseIdentifier, indexPath: indexPath, fixedHeight: 25) { (cell) in
            let cell = cell  as? SearchRecommendHotFilterCell
            cell?.bind(to: viewModel)
        }
    }
}
