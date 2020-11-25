//
//  InterestViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import ZLCollectionViewFlowLayout
import UICollectionView_ARDynamicHeightLayoutCell

class InterestViewController: CollectionViewController {

    private lazy var customNavigationBar: InterestNavigationBar = InterestNavigationBar.loadFromNib(height: 44, width: self.view.width)
    private lazy var dataSouce: RxCollectionViewSectionedReloadDataSource<SectionModel<Void, InterestCellViewModel>> = configureDataSouce()

    override func makeUI() {
        super.makeUI()

        navigationBar.addSubview(customNavigationBar)
        refreshComponent.accept(.none)

        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.minimumLineSpacing = 20

        collectionView.mj_header = nil
        collectionView.collectionViewLayout = layout
        collectionView.register(nibWithCellClass: InterestCell.self)
        collectionView.register(nib: InterestReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: InterestReusableView.self)

    }

    override func bindViewModel() {
        super.bindViewModel()

        guard let viewModel = viewModel as? InterestViewModel else { return }

        let refresh = Observable.just(())
        let input = InterestViewModel.Input(headerRefresh: refresh,
                                            selection: collectionView.rx.modelSelected(InterestCellViewModel.self).asObservable(),
                                            next: customNavigationBar.nextButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        dataSouce.configureSupplementaryView = configureSupplementaryView()
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.tabbar.drive(onNext: { () in
            guard let window = Application.shared.window else { return }
            Application.shared.showTabbar(provider: viewModel.provider, window: window)
        }).disposed(by: rx.disposeBag)

        collectionView.rx.contentOffset.map { $0.y }
            .subscribe(onNext: { [weak self] offsetY in
                guard let view = self?.customNavigationBar else { return }
                let height = Configs.BaseDimensions.navBarWithStatusBarHeight
                let alpha = (offsetY - height) / UIScreen.height * 10
                if offsetY > height {
                    view.titleLabel.alpha = alpha
                } else {
                    view.titleLabel.alpha = 0
                }
            }).disposed(by: rx.disposeBag)

    }
}
// MARK: - DataSouce
extension InterestViewController {

    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Void, InterestCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<Void, InterestCellViewModel>>(configureCell: { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: InterestCell.self)
            cell.bind(to: item)
            return cell
        })
    }
    fileprivate func configureSupplementaryView() -> (CollectionViewSectionedDataSource<SectionModel<Void, InterestCellViewModel>>, UICollectionView, String, IndexPath) -> UICollectionReusableView {
        return {  (dataSouce, collectionView, kind, indexPath) -> UICollectionReusableView in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: InterestReusableView.self, for: indexPath)
            return view
        }
    }

}

extension InterestViewController: ZLCollectionViewBaseFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 96)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let col: CGFloat = 2
        let width: CGFloat = collectionView.width - (inset * 2.0) - ((col - 1.0) * 15.0)
        let itemWidth = width / col
        return CGSize(width: itemWidth, height: 92)
    }
}
