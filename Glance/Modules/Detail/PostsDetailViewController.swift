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

        collectionView.headRefreshControl = nil
        collectionView.footRefreshControl = nil
        
        collectionView.register(PostsDetailCell.nib, forCellWithReuseIdentifier: PostsDetailCell.reuseIdentifier)

        collectionView.register(nib: PostsDetailBannerReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailBannerReusableView.self)

        collectionView.register(nib: PostsDetailPriceReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailPriceReusableView.self)

        collectionView.register(nib: PostsDetailTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailTitleReusableView.self)

        collectionView.register(nib: PostsDetailTagsReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailTagsReusableView.self)

        collectionView.register(nib: PostsDetailToolBarReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostsDetailToolBarReusableView.self)

        
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
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailTitleReusableView.self, for: indexPath)
                view.titleLabel.text = title
                view.titleLabel.font = UIFont.titleBoldFont(15)

                return view
            case .price(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailPriceReusableView.self, for: indexPath)
                //view.bind(to: viewModel)
                return view

            case .title(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostsDetailTitleReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                view.titleLabel.font = UIFont.titleFont(14)

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
            return CGSize(width: collectionView.width, height: 250)
        case .similar,.tagged:
            return CGSize(width: collectionView.width, height: 50)
        case .price:
            return CGSize(width: collectionView.width, height: 44)
        case .title:
//            return CGSize(width: collectionView.width, height: 44)

            return collectionView.ar_sizeForReusableView(withIdentifier: PostsDetailTitleReusableView.reuseIdentifier, indexPath: IndexPath(row: 0, section: section), fixedWidth: collectionView.width) { (cell) in
                let cell = cell  as? PostsDetailTitleReusableView
                if let viewModel = self.dataSouce.sectionModels[section].viewModel {
                    cell?.bind(to: viewModel)
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

        let collectionView = collectionView as! CollectionView
        let col = dataSouce[indexPath.section].column.cgFloat
        let width : CGFloat = collectionView.width - (inset * 2.0) - ((col - 1.0) * 15.0)
        let fixedWidth = width / col


        switch dataSouce.sectionModels[indexPath.section] {
        case .similar:
            return collectionView.ar_sizeForCell(withIdentifier: PostsDetailCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
                if case let .similar(viewModel) = self.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                    let cell = cell  as? PostsDetailCell
                    cell?.bind(to: viewModel)
                    cell?.setNeedsLayout()
                    cell?.layoutIfNeeded()
                }
            }
        case .tagged:
            return collectionView.ar_sizeForCell(withIdentifier: PostsDetailCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) { (cell) in
                if case let .tagged(viewModel) = self.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                    let cell = cell  as? PostsDetailCell
                    cell?.bind(to: viewModel)
                    cell?.setNeedsLayout()
                    cell?.layoutIfNeeded()

                }
            }
        default:
            fatalError()
        }
    }

}


