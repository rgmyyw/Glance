//
//  UserRecommViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
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

class UserDetailRecommViewController: CollectionViewController {

    private lazy var dataSouce: RxCollectionViewSectionedReloadDataSource<UserDetailRecommSection> = configureDataSouce()

    override func makeUI() {
        super.makeUI()

        navigationBar.isHidden = true
        viewDidLoadBeginRefresh = false

        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = 20

        collectionView.collectionViewLayout = layout
        DefaultColltionSectionItem.register(collectionView: collectionView, kinds: DefaultColltionCellType.all)

    }

    override func bindViewModel() {
        super.bindViewModel()

        guard let viewModel = viewModel as? UserDetailRecommViewModel else { return }

        let refresh = headerRefreshTrigger.asObservable().merge(with: rx.viewDidAppear.mapToVoid())
        let input = UserDetailRecommViewModel.Input(headerRefresh: refresh,
                                            footerRefresh: footerRefreshTrigger.mapToVoid(),
                                            selection: collectionView.rx.modelSelected(DefaultColltionSectionItem.self).asObservable())
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.detail.drive(onNext: { [weak self](item) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
            self?.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self?.topViewController())
        }).disposed(by: rx.disposeBag)

    }
}
// MARK: - DataSouce
extension UserDetailRecommViewController {

    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<UserDetailRecommSection> {
        return RxCollectionViewSectionedReloadDataSource<UserDetailRecommSection>(configureCell: { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .recommendPost(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductCell.self)
                cell.bind(to: viewModel)
                return cell
            case .recommendProduct(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductCell.self)
                cell.bind(to: viewModel)
                return cell
            default:
                fatalError()
            }
        })
    }

}

extension UserDetailRecommViewController: ZLCollectionViewBaseFlowLayoutDelegate {

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
        return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2, sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset), itemInset: 15)
        return collectionView.ar_sizeForCell(withIdentifier: ProductCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) {[weak self] (cell) in

            if let viewModel = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item].viewModel {
                let cell = cell  as? DefaultColltionCell
                cell?.bind(to: viewModel)
            }
        }

    }
}

extension UserDetailRecommViewController: WMZPageProtocol {

    func getMyScrollView() -> UIScrollView {
        return collectionView
    }

}
