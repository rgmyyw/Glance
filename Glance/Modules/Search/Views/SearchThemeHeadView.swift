//
//  SearchThemeLabelView.swift
//  Glance
//
//  Created by yanghai on 2020/9/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ZLCollectionViewFlowLayout
import RxSwift
import RxCocoa
import RxDataSources


class SearchThemeHeadView: View {

    lazy var dataSouce : RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchThemeLabelCellViewModel>> = configureDataSouce()

    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    
    @IBOutlet weak var postBgView: UIView!
    @IBOutlet weak var labelBgView: UIView!
    
    let items = BehaviorRelay<[SectionModel<Void,SearchThemeLabelCellViewModel>]>(value:[])
        
    override func makeUI() {
        super.makeUI()
        let layout = ZLCollectionViewHorzontalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = .zero
        collectionView.register(nibWithCellClass: SearchThemeLabelCell.self)
        items.asDriver().drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        items.asDriver().delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        
    }
  
}

// MARK: - DataSouce
extension SearchThemeHeadView {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchThemeLabelCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchThemeLabelCellViewModel>>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SearchThemeLabelCell.self)
            cell.bind(to: item)
            return cell
        })
    }
    
}

extension SearchThemeHeadView : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
        return collectionView.ar_sizeForCell(withIdentifier: SearchThemeLabelCell.reuseIdentifier, indexPath: indexPath, fixedHeight: 30) { (cell) in
            let cell = cell  as? SearchThemeLabelCell
            cell?.bind(to: viewModel)
        }
    }
}
