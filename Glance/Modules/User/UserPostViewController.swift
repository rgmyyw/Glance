//
//  UserPostViewController.swift
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

class UserPostViewController: CollectionViewController  {
    
    private lazy var dataSouce : RxCollectionViewSectionedReloadDataSource<SectionModel<Void,UserPostCellViewModel>> = configureDataSouce()
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.isHidden = true
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        collectionView.headRefreshControl = nil
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        collectionView.register(nibWithCellClass: UserPostCell.self)
        
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? UserPostViewModel else { return }
        
        
        
        let refresh = Observable<Void>.merge(Observable.just(()), headerRefreshTrigger)
        let input = UserPostViewModel.Input(headerRefresh: refresh,
                                            footerRefresh: footerRefreshTrigger.mapToVoid(),
                                            selection: collectionView.rx.modelSelected(UserPostCellViewModel.self).asObservable())
        let output = viewModel.transform(input: input)
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
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        
        
        output.detail.drive(onNext: { [weak self](item) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
            let controller = self?.topViewController
            self?.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: controller)
        }).disposed(by: rx.disposeBag)
        
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.noMoreData.bind(to: noMoreData).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: { (indexpATH) in
            let demo = DemoViewModel(provider: viewModel.provider)
            self.navigator.show(segue: .demo(viewModel: demo), sender: self)
        }).disposed(by: rx.disposeBag)
        
    }
}
// MARK: - DataSouce
extension UserPostViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Void,UserPostCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<Void,UserPostCellViewModel>>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UserPostCell.self)
            cell.bind(to: item)
            return cell
        })
    }
    
}

extension UserPostViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
        
        let collectionView = collectionView as! CollectionView
        return collectionView.ar_sizeForCell(withIdentifier: UserPostCell.reuseIdentifier, indexPath: indexPath, fixedWidth: collectionView.itemWidth(forItemsPerRow: 2)) {[weak self] (cell) in
            if let viewModel = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? UserPostCell
                cell?.bind(to: viewModel)
                cell?.setNeedsLayout()
                cell?.needsUpdateConstraints()
            }
        }
        
    }
}



extension UserPostViewController : WMZPageProtocol {
    
    func getMyScrollView() -> UIScrollView {
        return collectionView
    }
    
    
}
