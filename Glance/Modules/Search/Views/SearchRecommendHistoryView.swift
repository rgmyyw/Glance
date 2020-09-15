//
//  SearchRecommendHistoryView.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ZLCollectionViewFlowLayout
import RxSwift
import RxCocoa
import RxDataSources


class SearchRecommendHistoryView: View {

    lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<SearchRecommendHistorySection> = configureDataSouce()

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var clearButton: UIButton!
    let items = BehaviorRelay<[SearchRecommendHistorySection]>(value:[])
        
    override func makeUI() {
        super.makeUI()
        let layout = ZLCollectionViewHorzontalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = .zero
        collectionView.register(nibWithCellClass: SearchRecommendHistoryCell.self)
        items.asDriver().drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        items.asDriver().delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        
    }
  
}

// MARK: - DataSouce
extension SearchRecommendHistoryView {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<SearchRecommendHistorySection> {
        return RxCollectionViewSectionedAnimatedDataSource<SearchRecommendHistorySection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SearchRecommendHistoryCell.self)
            cell.bind(to: item.viewModel)
            return cell
        })
    }
    
}

extension SearchRecommendHistoryView : ZLCollectionViewBaseFlowLayoutDelegate {
    
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

        let viewModel =  dataSouce[indexPath.section].items[indexPath.item].viewModel
        return collectionView.ar_sizeForCell(withIdentifier: SearchRecommendHistoryCell.reuseIdentifier, indexPath: indexPath, fixedHeight: 30) { (cell) in
            let cell = cell  as? SearchRecommendHistoryCell
            cell?.bind(to: viewModel)
        }
    }
}
