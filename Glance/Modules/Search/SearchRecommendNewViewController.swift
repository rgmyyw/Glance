//
//  SearchRecommendYouMayLikeViewController.swift
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

class SearchRecommendNewViewController: CollectionViewController {

    private lazy var dataSouce: RxCollectionViewSectionedReloadDataSource<SearchRecommendNewSection> = configureDataSouce()

    override func makeUI() {
        super.makeUI()

        self.navigationBar.isHidden = true

        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self

        collectionView.collectionViewLayout = layout
        DefaultColltionSectionItem.register(collectionView: collectionView, kinds: DefaultColltionCellType.all)
    }

    override func bindViewModel() {
        super.bindViewModel()

        guard let viewModel = viewModel as? SearchRecommendNewViewModel else { return }

        let input = SearchRecommendNewViewModel.Input(headerRefresh: headerRefreshTrigger.asObservable(),
                                                             footerRefresh: footerRefreshTrigger.asObservable(),
                                                             selection: collectionView.rx.modelSelected(DefaultColltionSectionItem.self).asObservable())
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.reaction.subscribe(onNext: { [weak self] (fromView, cellViewModel) in
            ReactionPopManager.share.show(in: self?.collectionView, anchorView: fromView) { (selection ) in
                viewModel.selectionReaction.onNext((cellViewModel, selection))
            }
        }).disposed(by: rx.disposeBag)

        output.detail.drive(onNext: { [weak self](item) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
            self?.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.userDetail.drive(onNext: { [weak self](current) in
            let viewModel = UserDetailViewModel(provider: viewModel.provider, otherUser: current)
            self?.navigator.show(segue: .userDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

    }
}

extension SearchRecommendNewViewController {

    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SearchRecommendNewSection> {
        return RxCollectionViewSectionedReloadDataSource<SearchRecommendNewSection>(configureCell: { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .post(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostCell.self)
                cell.bind(to: viewModel)
                cell.saveButton.isHidden = true
                return cell
            case .theme(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ThemeCell.self)
                cell.bind(to: viewModel)
                return cell

            case .user(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserVerticalCell.self)
                cell.bind(to: viewModel)
                return cell

            case .product(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductCell.self)
                cell.bind(to: viewModel)
                cell.saveButton.isHidden = true
                return cell

            case .recommendPost(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostRecommendCell.self)
                cell.bind(to: viewModel)
                cell.saveButton.isHidden = true
                return cell

            case .recommendProduct(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductRecommendCell.self)
                cell.bind(to: viewModel)
                cell.saveButton.isHidden = true
                return cell
            case .none:
                fatalError()
            }
        })
    }

}

extension SearchRecommendNewViewController: ZLCollectionViewBaseFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSouce.sectionModels[section] {
        case.single:
            return .zero
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSouce.sectionModels[section] {
        case .single:
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2, sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset), itemInset: 15)

        let item = dataSouce.sectionModels[indexPath.section].items[indexPath.item]
        return collectionView.ar_sizeForCell(withIdentifier: item.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
            let cell = cell  as? DefaultColltionCell
            cell?.bind(to: item.viewModel)
        }

    }
}

extension SearchRecommendNewViewController: WMZPageProtocol {

    func getMyScrollView() -> UIScrollView {
        return collectionView
    }
}
