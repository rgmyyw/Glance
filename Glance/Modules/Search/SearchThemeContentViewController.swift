//
//  SearchResultContentViewController.swift
//  Glance
//
//  Created by yanghai on 2020/9/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import ZLCollectionViewFlowLayout
import UICollectionView_ARDynamicHeightLayoutCell
import WMZPageController

class SearchThemeContentViewController: CollectionViewController {

    private lazy var dataSouce: RxCollectionViewSectionedReloadDataSource<SearchResultContentViewSection> = configureDataSouce()

    override func makeUI() {
        super.makeUI()

        navigationBar.isHidden = true

        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

        collectionView.collectionViewLayout = layout
        DefaultColltionSectionItem.register(collectionView: collectionView, kinds: DefaultColltionCellType.all)
        collectionView.register(nibWithCellClass: UserHorizontalCell.self)

    }

    override func bindViewModel() {
        super.bindViewModel()

        guard let viewModel = viewModel as? SearchThemeContentViewModel else { return }
        let input = SearchThemeContentViewModel.Input(headerRefresh: headerRefreshTrigger.asObservable(),
                                        footerRefresh: footerRefreshTrigger.mapToVoid(),
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
            if current == user.value {
                let tabbar = UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarController
                tabbar?.setSelectIndex(from: tabbar?.selectedIndex ?? 0, to: 4)
            } else {
                let viewModel = UserDetailViewModel(provider: viewModel.provider, otherUser: current)
                self?.navigator.show(segue: .userDetail(viewModel: viewModel), sender: self)
            }
        }).disposed(by: rx.disposeBag)

    }
}

extension SearchThemeContentViewController {

    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SearchResultContentViewSection> {
        return RxCollectionViewSectionedReloadDataSource<SearchResultContentViewSection>(configureCell: { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in

            switch item {
            case .post(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostCell.self)
                cell.bind(to: viewModel)
                return cell
            case .theme(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ThemeCell.self)
                cell.bind(to: viewModel)
                return cell

            case .user(let viewModel) :

                switch dataSouce[indexPath.section] {
                case .single:
                    let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserVerticalCell.self)
                    cell.bind(to: viewModel)
                    return cell
                case .users:
                    let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserHorizontalCell.self)
                    cell.bind(to: viewModel)
                    return cell
                }

            case .product(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductCell.self)
                cell.bind(to: viewModel)
                return cell

            case .recommendPost(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostRecommendCell.self)
                cell.bind(to: viewModel)
                return cell

            case .recommendProduct(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductRecommendCell.self)
                cell.bind(to: viewModel)
                return cell
            case .none:
                fatalError()
            }
        })
    }

}

extension SearchThemeContentViewController: ZLCollectionViewBaseFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        switch dataSouce[section] {
        case .users:
            return 1
        default:
            return 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if dataSouce.sectionModels.isEmpty { return .zero }
        switch dataSouce.sectionModels[section] {
        case.single:
            return .zero
        case .users:
            return .zero
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if dataSouce.sectionModels.isEmpty { return .zero }
        switch dataSouce.sectionModels[section] {
        case .single:
            return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
        case .users:
            return .zero
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if dataSouce.sectionModels.isEmpty { return .zero }

        let fixedWidth: CGFloat
        let reuseIdentifier: String

        let item = dataSouce.sectionModels[indexPath.section].items[indexPath.item]
        switch dataSouce.sectionModels[indexPath.section] {
        case .single:
            fixedWidth = collectionView.itemWidth(forItemsPerRow: 2, sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset), itemInset: 15)
            reuseIdentifier = dataSouce.sectionModels[indexPath.section].items[indexPath.item].reuseIdentifier
        default:
            fixedWidth = collectionView.width
            reuseIdentifier = UserHorizontalCell.reuseIdentifier
        }
        return collectionView.ar_sizeForCell(withIdentifier: reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
            let cell = cell  as? DefaultColltionCell
            cell?.bind(to: item.viewModel)
        }

    }
}

extension SearchThemeContentViewController: WMZPageProtocol {

    func getMyScrollView() -> UIScrollView {
        return collectionView
    }
}
