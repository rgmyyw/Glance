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
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.addSubview(customNavigationBar)

        let layout = ZLCollectionViewVerticalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = inset
        layout.minimumInteritemSpacing = 15

        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
        collectionView.register(nibWithCellClass: PostsDetailCell.self)
        collectionView.headRefreshControl = nil
        collectionView.footRefreshControl = nil
        collectionView.register(nib: PostsDetailHeadReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailHeadReusableView.self)
        collectionView.register(nib: PostsDetailTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailTitleReusableView.self)
        
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? PostsDetailViewModel else { return }
        let input = PostsDetailViewModel.Input(selection: collectionView.rx.modelSelected(PostsDetailSectionItem.self).asObservable())
        let output = viewModel.transform(input: input)
        dataSouce.configureSupplementaryView = configureSupplementaryView()
        output.userName.drive(customNavigationBar.userNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.userImageURL.drive(customNavigationBar.userImageView.rx.imageURL).disposed(by: rx.disposeBag)
        output.time.drive(customNavigationBar.timeLabel.rx.text).disposed(by: rx.disposeBag)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
                
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.noMoreData.bind(to: noMoreData).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
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
            case .head(let viewModel) :
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailHeadReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view
            case .similar(let title, _),.tagged(let title, _):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailTitleReusableView.self, for: indexPath)
                view.titleLabel.text = title
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
        switch dataSouce.sectionModels[section] {
        case .head:
            return 0
        case .similar:
            return 2
        case .tagged:
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSouce.sectionModels[section] {
        case .head(let viewModel):
            return CGSize(width: collectionView.width, height: 450)
        case .similar,.tagged:
            return CGSize(width: collectionView.width, height: 50)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSouce.sectionModels[section] {
        case .head:
            return .zero
        case .similar,.tagged:
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let collectionView = collectionView as! CollectionView
        let col = dataSouce[indexPath.section].column.cgFloat
        let width : CGFloat = collectionView.width - (inset * 2.0) - ((col - 1.0) * 15.0)
        let fixedWidth = width / col
        
        return collectionView.ar_sizeForCell(withIdentifier: PostsDetailCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth + 18) {[weak self] (cell) in
            
            if case let .similar(viewModel) = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? PostsDetailCell
                cell?.bind(to: viewModel)
                cell?.setNeedsLayout()
                cell?.layoutIfNeeded()
                
            }
            
            if case let .tagged(viewModel) = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? PostsDetailCell
                cell?.bind(to: viewModel)
                cell?.setNeedsLayout()
                cell?.layoutIfNeeded()
            }
        }
    }
    
}


