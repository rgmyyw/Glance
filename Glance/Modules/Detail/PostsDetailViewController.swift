//
//  PostsDetailViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ZLCollectionViewFlowLayout
import RxSwift
import RxCocoa
import RxDataSources
import DropDown

class PostsDetailViewController: CollectionViewController {

    private lazy var dataSouce: RxCollectionViewSectionedReloadDataSource<PostsDetailSection> = configureDataSouce()
    private lazy var customNavigationBar: PostsDetailNavigationBar = PostsDetailNavigationBar.loadFromNib(height: 44, width: self.view.width)
    private lazy var bottomBar: PostsDetailBottomBar = PostsDetailBottomBar.loadFromNib(height: UIApplication.shared.statusBarFrame.height == 20 ? 62 : 42, width: self.view.width)

    lazy var memu: DropDownView = {
        let view = DropDownView(anchorView: customNavigationBar.moreButton)
        view.dd_shadowColor = UIColor(hex: 0x696969)!
        view.dd_shadowOpacity = 0.5
        view.dd_cornerRadius = 5
        view.dd_shadowOffset = CGSize(width: 0, height: 2)
        view.textFont = UIFont.titleFont(12)
        view.cellHeight = 32
        view.animationduration = 0.25
        let width: CGFloat = 100
        view.dd_width = width
        view.bottomOffset = CGPoint(x: -(width - 15), y: customNavigationBar.moreButton.height + 5)

        return view
    }()

    override func makeUI() {
        super.makeUI()

        navigationBar.addSubview(customNavigationBar)
        stackView.addArrangedSubview(bottomBar)
        refreshComponent.accept(.footer)

        let layout = ZLCollectionViewVerticalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = inset
        layout.minimumInteritemSpacing = 15

        collectionView.collectionViewLayout = layout

        collectionView.register(ProductCell.nib, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        collectionView.register(nib: PostsDetailMoreReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailMoreReusableView.self)

        collectionView.register(nib: PostsDetailBannerReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailBannerReusableView.self)
        collectionView.register(nib: PostsDetailPriceReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailPriceReusableView.self)
        collectionView.register(nib: PostsDetailTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailTitleReusableView.self)
        collectionView.register(nib: PostsDetailTagsReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailTagsReusableView.self)
        collectionView.register(nib: PostsDetailToolBarReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailToolBarReusableView.self)
        collectionView.register(nib: PostsDetailSectionTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailSectionTitleReusableView.self)
        emptyDataSource.enable.accept(true)

    }

    override func bindViewModel() {
        super.bindViewModel()

        guard let viewModel = viewModel as? PostsDetailViewModel else { return }
        dataSouce.configureSupplementaryView = configureSupplementaryView()

        let footerRefresh = Observable.just(()).merge(with: footerRefreshTrigger.asObservable())
        let input = PostsDetailViewModel.Input(footerRefresh: footerRefresh,
                                               selection: collectionView.rx.modelSelected(DefaultColltionSectionItem.self).asObservable(),
                                               bottomButtonTrigger: bottomBar.backgroundView.rx.tap(),
                                               memu: customNavigationBar.moreButton.rx.tap.asObservable(),
                                               memuSelection: memu.selection())
        let output = viewModel.transform(input: input)
        output.userName.drive(customNavigationBar.ownNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.userName.drive(customNavigationBar.otherNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.userImageURL.drive(customNavigationBar.ownImageView.rx.imageURL).disposed(by: rx.disposeBag)
        output.userImageURL.drive(customNavigationBar.otherImageView.rx.imageURL).disposed(by: rx.disposeBag)
        output.time.drive(customNavigationBar.ownTimeLabel.rx.text).disposed(by: rx.disposeBag)
        output.time.drive(customNavigationBar.otherTimeLabel.rx.text).disposed(by: rx.disposeBag)
        output.time.drive(customNavigationBar.productTimeLabel.rx.text).disposed(by: rx.disposeBag)
        output.productName.drive(customNavigationBar.productNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.bottomBarHidden.drive(bottomBar.rx.isHidden).disposed(by: rx.disposeBag)
        output.bottomBarTitle.drive(bottomBar.titleLabel.rx.text).disposed(by: rx.disposeBag)
        output.bottomBarAddButtonHidden.drive(bottomBar.addButton.rx.isHidden).disposed(by: rx.disposeBag)
        output.bottomBarBackgroundColor.drive(bottomBar.backgroundView.rx.backgroundColor).disposed(by: rx.disposeBag)

        output.shoppingCart.drive(onNext: { [weak self]() in
            let viewModel = ShoppingCartViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .shoppingCart(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.navigationBarType
            .drive(onNext: { [weak self](type) in
                self?.customNavigationBar.items[type].isHidden = false
        }).disposed(by: rx.disposeBag)

        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.detail
            .drive(onNext: { (item) in
                let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
                self.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.delete
            .drive(onNext: { () in
                let title = "Delete your post?"
                let message = "Your post will be deleted."
                Alert.showAlert(with: title,
                                message: message,
                                optionTitles: "DELETE",
                                cancel: "CANCEL")
                    .subscribe(onNext: { index in
                        if index == 0 { viewModel.deletePost.onNext(()) }
                    }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)

        customNavigationBar.backButton.rx
            .tap.subscribe(onNext: { [weak self]() in
                self?.navigator.pop(sender: self)
            }).disposed(by: rx.disposeBag)

        output.popMemu.drive(onNext: { [weak self](items) in
            guard let self = self else { return }
            self.memu.dataSource = items.map { "  \($0.title)"}
            self.memu.show()
        }).disposed(by: rx.disposeBag)

        output.back.delay(RxTimeInterval.milliseconds(1000))
            .drive(onNext: { [weak self](_) in
            self?.navigator.pop(sender: self)
        }).disposed(by: rx.disposeBag)

        output.viSearch.drive(onNext: { [weak self](image) in
            let viewModel = VisualSearchViewModel(provider: viewModel.provider, image: image)
            self?.navigator.show(segue: .visualSearch(viewModel: viewModel), sender: self, transition: .modal)
        }).disposed(by: rx.disposeBag)

        output.openURL.drive(onNext: { [weak self] (url) in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self?.exceptionError.onNext(.general("not open the url:\(url.absoluteString)"))
            }
        }).disposed(by: rx.disposeBag)

        output.selectStore.drive(onNext: { [weak self] (productId) in
            guard let self = self else { return }
            let selectStore = SelectStoreViewModel(provider: viewModel.provider, productId: productId)
            selectStore.action.bind(to: viewModel.selectStoreActions).disposed(by: self.rx.disposeBag)
            self.navigator.show(segue: .selectStore(viewModel: selectStore), sender: self, transition: .panel(style: .default))
        }).disposed(by: rx.disposeBag)

        output.reloadSection.delay(RxTimeInterval.milliseconds(200))
            .drive(onNext: { [weak self](section) in
                //CATransaction.begin()
                //CATransaction.setDisableActions(true)
                //self?.collectionView.reloadSections(IndexSet(integer: section))
                //CATransaction.commit()
                self?.collectionView.reloadSections(IndexSet(integer: section))
                //UIView.performWithoutAnimation {
                    //self?.collectionView.reloadSections(IndexSet(integer: section))
                //}
        }).disposed(by: rx.disposeBag)

    }
}

extension PostsDetailViewController {

    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<PostsDetailSection> {
        return RxCollectionViewSectionedReloadDataSource<PostsDetailSection>(configureCell: { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .product(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductCell.self)
                cell.moreContentView.isHidden = true
                cell.bind(to: viewModel)

                switch dataSouce[indexPath.section] {
                case .tagged:
                    cell.titleLabel.font = UIFont.titleBoldFont(10)
                case .similar:
                   cell.titleLabel.font = UIFont.titleBoldFont(12)
                default: break
                }
                return cell
            default:
                fatalError()
            }

        })
    }

    fileprivate func configureSupplementaryView() -> (CollectionViewSectionedDataSource<PostsDetailSection>, UICollectionView, String, IndexPath) -> UICollectionReusableView {
        return {  (dataSouce, collectionView, kind, indexPath) -> UICollectionReusableView in

            switch dataSouce.sectionModels[indexPath.section] {
            case .banner(let viewModel) :
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailBannerReusableView.self, for: indexPath)
                view.bind(to: viewModel)

                return view
            case .similar(let title, _), .tagged(let title, _):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailSectionTitleReusableView.self, for: indexPath)
                view.titleLabel.text = title

                return view
            case .price(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailPriceReusableView.self, for: indexPath)
                view.bind(to: viewModel)

                return view

            case .title(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailTitleReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view

            case .more(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailMoreReusableView.self, for: indexPath)
                view.bind(to: viewModel)

                return view
            case .tags(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailTagsReusableView.self, for: indexPath)
                view.bind(to: viewModel)

                return view

            case .tool(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailToolBarReusableView.self, for: indexPath)
                view.bind(to: viewModel)

                return view

            }
        }
    }

}

extension PostsDetailViewController: ZLCollectionViewBaseFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return dataSouce.sectionModels[section].column
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        switch dataSouce.sectionModels[section] {
        case .banner(let viewModel):
            return CGSize(width: collectionView.width, height: viewModel.bannerHeight)
        case .similar, .tagged:
            return CGSize(width: collectionView.width, height: 50)
        case .price:
            return CGSize(width: collectionView.width, height: 30)
        case .title(let viewModel):
            return CGSize(width: collectionView.width, height: viewModel.folded.value ? viewModel.titleFoldedHeight : viewModel.titleExpendHeight)
//            return collectionView.ar_size(forReusableViewHeightIdentifier: PostsDetailTitleReusableView.reuseIdentifier, indexPath: IndexPath(row: 0, section: section), fixedWidth: collectionView.width - 40) { (cell) in
//                let cell = cell  as? PostsDetailTitleReusableView
//                if let viewModel = self.dataSouce.sectionModels[section].viewModel {
//                    cell?.bind(to: viewModel)
//                    cell?.setNeedsLayout()
//                    cell?.layoutIfNeeded()
//                }
//            }

        case .tags:
            return CGSize(width: collectionView.width, height: 100)
        case .tool:
            return CGSize(width: collectionView.width, height: 50)
        case .more:
            return CGSize(width: collectionView.width, height: 28)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSouce.sectionModels[section] {
        case .similar, .tagged:
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        default:
            return .zero
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        let section = dataSouce[indexPath.section]
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: section.column, sectionInset: sectionInset, itemInset: 15)

        let item = dataSouce.sectionModels[indexPath.section].items[indexPath.item]
        return collectionView.ar_sizeForCell(withIdentifier: item.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
            let cell = cell  as? ProductCell
            cell?.moreContentView.isHidden = true
            cell?.bind(to: item.viewModel)
            switch section {
            case .tagged:
                cell?.titleLabel.font = UIFont.titleBoldFont(10)
            case .similar:
                cell?.titleLabel.font = UIFont.titleBoldFont(12)
            default:break
            }

        }

    }

}
