//
//  SearchRecommendHotCell.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ZLCollectionViewFlowLayout

class SearchRecommendHotCell: TableViewCell {
    
    @IBOutlet weak var themeTitleLabel: UILabel!
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var dataSouce : RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotColltionCellViewModel>> = configureDataSouce()

    @IBOutlet weak var themeDetailBgView: UIView!
    
    override func makeUI() {
        super.makeUI()
        let layout = ZLCollectionViewHorzontalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 80, height: 120)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = .zero
        collectionView.register(nibWithCellClass: SearchRecommendHotCollectionCell.self)
    }
    
    
    override func bind<T>(to viewModel: T) where T : SearchRecommendHotCellViewModel {
        super.bind(to: viewModel)
        viewModel.title.bind(to: themeTitleLabel.rx.text).disposed(by: cellDisposeBag)
        viewModel.post.bind(to: postNumberLabel.rx.text).disposed(by: cellDisposeBag)
        
        viewModel.items.asDriver().drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: cellDisposeBag)
        viewModel.items.asDriver().delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: cellDisposeBag)
        
        themeDetailBgView.rx.tap().bind(to: viewModel.themeDetail).disposed(by: cellDisposeBag)

    }
}

// MARK: - DataSouce
extension SearchRecommendHotCell {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotColltionCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SearchRecommendHotColltionCellViewModel>>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SearchRecommendHotCollectionCell.self)
            cell.bind(to: item)
            return cell
        })
    }
    
}

extension SearchRecommendHotCell : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
    
}
