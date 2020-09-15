//
//  HomeController.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import ZLCollectionViewFlowLayout
import UICollectionView_ARDynamicHeightLayoutCell
import Popover

class HomeController: CollectionViewController {
    
    private lazy var customNavigationBar : HomeNavigationBar = HomeNavigationBar.loadFromNib(height: 44,width: self.view.width)
    private lazy var dataSouce : RxCollectionViewSectionedReloadDataSource<HomeSection> = configureDataSouce()


    override func makeUI() {
        super.makeUI()
        
        navigationBar.addSubview(customNavigationBar)
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        //collectionView.register(nibWithCellClass: HomeCell.self)
            
        DefaultColltionSectionItem.register(collectionView: collectionView, kinds: HomeCellType.all)

        
    }


    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? HomeViewModel else { return }
        
        let refresh = Observable<Void>.merge(Observable.just(()), headerRefreshTrigger,NotificationCenter.default.rx.notification(.kUpdateHomeData).mapToVoid())
        let input = HomeViewModel.Input(headerRefresh: refresh,
                                        footerRefresh: footerRefreshTrigger.mapToVoid(),
                                        selection: collectionView.rx.modelSelected(DefaultColltionSectionItem.self).asObservable(), search: customNavigationBar.searchView.rx.tap())
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.reaction.subscribe(onNext: { [weak self] (fromView,cellViewModel) in
            ReactionPopManager.share.show(in: self?.collectionView, anchorView: fromView) { (selection ) in
                viewModel.selectionReaction.onNext((cellViewModel,selection))
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
                let viewModel = UserViewModel(provider: viewModel.provider, otherUser: current)
                self?.navigator.show(segue: .user(viewModel: viewModel), sender: self)
            }
        }).disposed(by: rx.disposeBag)
        

        customNavigationBar.shoppingCartButton
            .rx.tap.subscribe(onNext: { [weak self]() in
                let viewModel = ShoppingCartViewModel(provider: viewModel.provider)
                self?.navigator.show(segue: .shoppingCart(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
        customNavigationBar.savedButton
            .rx.tap.subscribe(onNext: { [weak self]() in
                let viewModel = SavedCollectionClassifyViewModel(provider: viewModel.provider)
                self?.navigator.show(segue: .savedCollectionClassify(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        input.search.subscribe(onNext: {[weak self] () in
            let viewModel = SearchRecommendViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .searchRecommend(viewModel: viewModel), sender: self)
            
        }).disposed(by: rx.disposeBag)
        
        
        NotificationCenter.default.rx
            .notification(.kUpdateHomeData)
            .map { $0.userInfo as? [String : String]}
            .map { $0?["message"]}.filterNil()
            .map { Message($0)}.bind(to: message)
            .disposed(by: rx.disposeBag)
        
        
    }
}

extension HomeController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<HomeSection> {
        return RxCollectionViewSectionedReloadDataSource<HomeSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .post(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostCell.self)
                cell.bind(to: viewModel)
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

extension HomeController : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
            return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2,sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset),itemInset: 15)
        
        let item = dataSouce.sectionModels[indexPath.section].items[indexPath.item]
        return collectionView.ar_sizeForCell(withIdentifier: item.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
            let cell = cell  as? DefaultColltionCell
            cell?.bind(to: item.viewModel)
        }

    }
}


