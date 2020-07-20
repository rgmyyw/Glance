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
        collectionView.register(nibWithCellClass: HomeCell.self)
        
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? HomeViewModel else { return }        
        
        let refresh = Observable<Void>.merge(Observable.just(()), headerRefreshTrigger)
        let input = HomeViewModel.Input(headerRefresh: refresh,
                                        footerRefresh: footerRefreshTrigger.mapToVoid(),
                                        selection: collectionView.rx.modelSelected(HomeSectionItem.self).asObservable())
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.showLikePopView
            .subscribe(onNext: { (fromView,cellViewModel) in
                let width = 120
                let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 48))
                let options: [PopoverOption] = [.type(.down),.sideOffset(100),.sideEdge(20),
                                                .color(UIColor.black.withAlphaComponent(0.5)),
                                                .cornerRadius(8),.arrowSize(.zero), .showBlackOverlay(false)]
                let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
                popover.show(aView, fromView: fromView)
                
        }).disposed(by: rx.disposeBag)
        
        output.postDetail.subscribe(onNext: { (item) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
            self.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
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

        
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.noMoreData.bind(to: noMoreData).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        
    }
}

extension HomeController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<HomeSection> {
        return RxCollectionViewSectionedReloadDataSource<HomeSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .recommendItem(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: HomeCell.self)
                cell.bind(to: viewModel)
                return cell
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
        case.recommend:
            return .zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSouce.sectionModels[section] {
        case .recommend:
            return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionView = collectionView as! CollectionView
        return collectionView.ar_sizeForCell(withIdentifier: HomeCell.reuseIdentifier, indexPath: indexPath, fixedWidth: collectionView.itemWidth(forItemsPerRow: 2)) {[weak self] (cell) in
            if case let .recommendItem(viewModel) = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? HomeCell
                cell?.bind(to: viewModel)
                cell?.setNeedsLayout()
                cell?.needsUpdateConstraints()
            }
        }
        
    }
}


