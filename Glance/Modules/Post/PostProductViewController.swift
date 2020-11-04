//
//  PostProductViewController.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ZLCollectionViewFlowLayout
import RxSwift
import RxCocoa
import RxDataSources

class PostProductViewController: CollectionViewController {
    
    private lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<PostProductSection> = configureDataSouce()
    
    lazy var postButton : UIButton = {
        let postButton = UIButton()
        postButton.setTitle("POST", for: .normal)
        postButton.setTitleColor(UIColor.primary(), for: .normal)
        postButton.titleLabel?.font = UIFont.titleFont(15)
        return postButton
    }()
    
    
    lazy var navigationImageView  : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.cornerRadius = 10
        return imageView
    }()
    
    
    override func makeUI() {
        super.makeUI()
        
        
        refreshComponent.accept(.none)
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        
        let spec = View(height: 35)
        stackView.insertArrangedSubview(spec, at: 0)
        
        collectionView.collectionViewLayout = layout
        collectionView.register(PostProductTagCell.nib, forCellWithReuseIdentifier: PostProductTagCell.reuseIdentifier)
        collectionView.register(PostProductCell.nib, forCellWithReuseIdentifier: PostProductCell.reuseIdentifier)

        
        collectionView.register(nib: PostProductCaptionReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostProductCaptionReusableView.self)
        collectionView.register(nib: PostProductInputKeywordReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostProductInputKeywordReusableView.self)
        collectionView.register(nib: PostProductTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: PostProductTitleReusableView.self)

        navigationBar.rightBarButtonItem = postButton
        emptyDataSource.enable.accept(false)
        
    }

    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? PostProductViewModel else { return }
        
        let input = PostProductViewModel.Input(selection: collectionView.rx.modelSelected(PostProductSectionItem.self).asObservable(),
                                               commit: postButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        dataSouce.configureSupplementaryView = configureSupplementaryView()

        output.navigationImage.drive(navigationImageView.rx.image).disposed(by: rx.disposeBag)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
    
        output.complete
            .drive(onNext: { [weak self]() in
                self?.navigationController?.dismiss(animated: true, completion: {
                    let tabbar = UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarController
                    tabbar?.setSelectIndex(from: tabbar?.selectedIndex ?? 0, to: 0)
                    let userInfo = ["message" : "Post completed"]
                    NotificationCenter.default.post(.init(name: .kUpdateHomeData, object: nil,
                                                          userInfo: userInfo))
                })
        }).disposed(by: rx.disposeBag)
        
        output.detail.drive(onNext: { [weak self](productId) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: DefaultColltionItem(productId: productId))
            self?.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
        
        viewModel.reselection
        .mapToVoid().subscribe(onNext: { [weak self]() in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func updateUI() {
        super.updateUI()
        
        if navigationImageView.superview == nil {
            navigationBar.clipsToBounds = false
            navigationBar.superview?.addSubview(navigationImageView)
        }
        navigationImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(navigationBar.snp.centerX)
            make.centerY.equalTo(navigationBar.snp.bottom)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
    
}

extension PostProductViewController {

    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<PostProductSection> {
        return RxCollectionViewSectionedAnimatedDataSource<PostProductSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in

            switch item {
            case .product(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostProductCell.self)
                cell.bind(to: viewModel)
                return cell
            case .tag(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostProductTagCell.self)
                cell.bind(to: viewModel)
                return cell
            }
        })
    }


    fileprivate func configureSupplementaryView() -> (CollectionViewSectionedDataSource<PostProductSection>, UICollectionView, String, IndexPath) -> UICollectionReusableView {
        return {  (dataSouce, collectionView, kind, indexPath) -> UICollectionReusableView in

            switch dataSouce.sectionModels[indexPath.section] {

            case .caption(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostProductCaptionReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view

            case .tagRelatedKeywords(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostProductInputKeywordReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view

            case .systemTags(let title, _),.tagged(let title, _):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: PostProductTitleReusableView.self, for: indexPath)
                view.titleLabel.text = title
                return view
            default:
                fatalError()
            }

        }
    }


}


extension PostProductViewController : ZLCollectionViewBaseFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        switch self.dataSouce[section] {
        case .systemTags,.customTags:
            return LabelLayout
        default:
            return ClosedLayout
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        switch self.dataSouce[section] {
        case .tagged:
            return 1
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSouce.sectionModels[section] {
        case .caption:
            return CGSize(width: collectionView.width, height: 135)
        case .tagRelatedKeywords:
            return CGSize(width: collectionView.width, height: 125)
        case .systemTags,.tagged:
            return CGSize(width: collectionView.width, height: 50)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSouce.sectionModels[section] {
        case .customTags,.systemTags:
            return  UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        case .tagged:
            return  UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let item =  dataSouce[indexPath.section].items[indexPath.item]
        switch item {
        case .tag(let viewModel):
            return collectionView.ar_sizeForCell(withIdentifier: PostProductTagCell.reuseIdentifier, indexPath: indexPath, fixedHeight: 25) { (cell) in
                let cell = cell  as? PostProductTagCell
                cell?.bind(to: viewModel)

            }
        case .product:
            return CGSize(width: collectionView.width, height: 120)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch self.dataSouce[section] {
        case .systemTags,.customTags:
            return 10
        default:
            return 0
        }
    }
}


