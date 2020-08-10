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

class PostsDetailViewController: CollectionViewController {
    
    private lazy var dataSouce : RxCollectionViewSectionedReloadDataSource<PostsDetailSection> = configureDataSouce()
    private lazy var customNavigationBar : PostsDetailNavigationBar = PostsDetailNavigationBar.loadFromNib(height: 44,width: self.view.width)
    private lazy var bottomBar : PostsDetailBottomBar = PostsDetailBottomBar.loadFromNib(height: UIApplication.shared.statusBarFrame.height == 20 ? 62 : 42,width: self.view.width)

    
    override func makeUI() {
        super.makeUI()
        
        
        navigationBar.addSubview(customNavigationBar)
        stackView.addArrangedSubview(bottomBar)
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = inset
        layout.minimumInteritemSpacing = 15
        
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)

        collectionView.headRefreshControl = nil
//        collectionView.footRefreshControl = nil
        
        collectionView.register(PostsDetailCell.nib, forCellWithReuseIdentifier: PostsDetailCell.reuseIdentifier)
        collectionView.register(nib: PostsDetailBannerReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailBannerReusableView.self)
        collectionView.register(nib: PostsDetailPriceReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailPriceReusableView.self)
        collectionView.register(nib: PostsDetailTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailTitleReusableView.self)
        collectionView.register(nib: PostsDetailTagsReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailTagsReusableView.self)
        collectionView.register(nib: PostsDetailToolBarReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailToolBarReusableView.self)
        collectionView.register(nib: PostsDetailSectionTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailSectionTitleReusableView.self)
        emptyDataViewDataSource.enable.accept(false)
        
    }

    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? PostsDetailViewModel else { return }
        dataSouce.configureSupplementaryView = configureSupplementaryView()
        
        let footerRefresh = Observable.just(()).merge(with: footerRefreshTrigger.asObservable())
        let input = PostsDetailViewModel.Input(footerRefresh: footerRefresh,
                                               selection: collectionView.rx.modelSelected(PostsDetailSectionItem.self).asObservable(),
                                               bottomButtonTrigger: bottomBar.backgroundView.rx.tap())
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
        
        customNavigationBar.backButton.rx
            .tap.subscribe(onNext: { [weak self]() in
                self?.navigator.pop(sender: self)
            }).disposed(by: rx.disposeBag)
    }
}

extension PostsDetailViewController {

    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<PostsDetailSection> {
        return RxCollectionViewSectionedReloadDataSource<PostsDetailSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            
            switch item {
            case .tagged(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostsDetailCell.self)
                cell.titleLabel.font = UIFont.titleBoldFont(10)
                cell.bind(to: viewModel)
               
                return cell
            case .similar(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostsDetailCell.self)
                cell.titleLabel.font = UIFont.titleBoldFont(12)
                cell.bind(to: viewModel)
               
                return cell
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
            case .similar(let title, _),.tagged(let title, _):
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


extension PostsDetailViewController : ZLCollectionViewBaseFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return dataSouce.sectionModels[section].column
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {


        switch dataSouce.sectionModels[section] {
        case .banner:
            return CGSize(width: collectionView.width, height: 350)
        case .similar,.tagged:
            return CGSize(width: collectionView.width, height: 50)
        case .price:
            return CGSize(width: collectionView.width, height: 30)
        case .title:
            return collectionView.ar_size(forReusableViewHeightIdentifier: PostsDetailTitleReusableView.reuseIdentifier, indexPath: IndexPath(row: 0, section: section), fixedWidth: collectionView.width - 40) { (cell) in
                let cell = cell  as? PostsDetailTitleReusableView
                if let viewModel = self.dataSouce.sectionModels[section].viewModel {
                    cell?.bind(to: viewModel)
                    cell?.setNeedsLayout()
                    cell?.layoutIfNeeded()
                }
            }
        case .tags:
            return CGSize(width: collectionView.width, height: 100)
        case .tool:
            return CGSize(width: collectionView.width, height: 50)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {


        switch dataSouce.sectionModels[section] {
        case .similar,.tagged:
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        default:
            return .zero
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = dataSouce[indexPath.section].items[indexPath.item].viewModel
        viewModel.column = dataSouce[indexPath.section].column.cgFloat
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: dataSouce[indexPath.section].column,sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset),itemInset: 15)
        
        switch dataSouce.sectionModels[indexPath.section] {
        case .similar:
            return collectionView.ar_sizeForCell(withIdentifier: PostsDetailCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
                let cell = cell  as? PostsDetailCell
                cell?.bind(to: viewModel)
                
            }
        case .tagged:
            return collectionView.ar_sizeForCell(withIdentifier: PostsDetailCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
                let cell = cell  as? PostsDetailCell
                cell?.bind(to: viewModel)
            }
        default:
            fatalError()
        }
    }

}


