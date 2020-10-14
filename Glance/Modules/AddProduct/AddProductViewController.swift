//
//  AddProductViewController.swift
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

class AddProductViewController: CollectionViewController {
    
    private lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<AddProductSection> = configureDataSouce()
    
    override func makeUI() {
        super.makeUI()
        
        refreshComponent.accept(.none)
        emptyDataViewDataSource.enable.accept(false)
        navigationTitle = "Add Product"
        
        
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.delegate = self
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        collectionView.collectionViewLayout = layout
        collectionView.register(AddProductTagCell.nib, forCellWithReuseIdentifier: AddProductTagCell.reuseIdentifier)
        collectionView.register(AddProductImageCell.nib, forCellWithReuseIdentifier: AddProductImageCell.reuseIdentifier)
        
        
        collectionView.register(nib: AddProductNameReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: AddProductNameReusableView.self)
        collectionView.register(nib: AddProductCategaryReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: AddProductCategaryReusableView.self)
        collectionView.register(nib: AddProductInputKeywordReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: AddProductInputKeywordReusableView.self)
        collectionView.register(nib: AddProductBrandReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: AddProductBrandReusableView.self)
        collectionView.register(nib: AddProductWebsiteReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: AddProductWebsiteReusableView.self)
        collectionView.register(nib: AddProductButtonReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: AddProductButtonReusableView.self)
        collectionView.register(nib: AddProductTitleReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: AddProductTitleReusableView.self)
        
        
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? AddProductViewModel else { return }
        
        let input = AddProductViewModel.Input(selection: collectionView.rx.modelSelected(AddProductSectionItem.self).asObservable())
        let output = viewModel.transform(input: input)
        dataSouce.configureSupplementaryView = configureSupplementaryView()
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        
        output.selectionCategory
            .drive(onNext: {[weak self] (items) in
                guard let self = self else { return }
                let titles = items.compactMap { $0.name }
                Alert.showActionSheet(message: "", optionTitles: titles)
                    .subscribe(onNext: { (index) in
                        if index >= 0 {
                            viewModel.selectedCategory.onNext(items[index])
                        }
                    }).disposed(by: self.rx.disposeBag)
            }).disposed(by: rx.disposeBag)
        
        output.post.subscribe(onNext: { [weak self](box,home) in
            
            NotificationCenter.default.post(name: .kAddProduct, object: (box,home))
            self?.navigator.pop(sender: self, toRoot: true)
            /// let viewModel = PostProductViewModel(provider: viewModel.provider, image: image,taggedItems: [(box,home)])
            /// self.navigator.show(segue: .postProduct(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
    }
}

extension AddProductViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<AddProductSection> {
        return RxCollectionViewSectionedAnimatedDataSource<AddProductSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            
            switch item {
            case .thumbnail(_,let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: AddProductImageCell.self)
                cell.bind(to: viewModel)
                return cell
            case .tag(_,let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: AddProductTagCell.self)
                cell.bind(to: viewModel)
                return cell
            }
        })
    }
    
    
    fileprivate func configureSupplementaryView() -> (CollectionViewSectionedDataSource<AddProductSection>, UICollectionView, String, IndexPath) -> UICollectionReusableView {
        return {  (dataSouce, collectionView, kind, indexPath) -> UICollectionReusableView in
            
            switch dataSouce.sectionModels[indexPath.section] {
            case .brand(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: AddProductBrandReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view
                
            case .categary(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: AddProductCategaryReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view
                
            case .productName(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: AddProductNameReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view
                
            case .tagRelatedKeywords(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: AddProductInputKeywordReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view
                
            case .thumbnail:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: AddProductTitleReusableView.self, for: indexPath)
                return view
                
            case .website(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: AddProductWebsiteReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view
            case .button(let viewModel):
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: AddProductButtonReusableView.self, for: indexPath)
                view.bind(to: viewModel)
                return view
            default:
                fatalError()
            }
            
        }
    }
    
    
}


extension AddProductViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        switch self.dataSouce[section] {
        case .tags:
            return LabelLayout
        case .thumbnail:
            return ColumnLayout
        default:
            return ClosedLayout
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        switch self.dataSouce[section] {
        case .thumbnail:
            return 3
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSouce.sectionModels[section] {
        case .tagRelatedKeywords:
            return CGSize(width: collectionView.width, height: 125)
        case .thumbnail:
            return CGSize(width: collectionView.width, height: 60)
        case .categary,.productName,.brand,.website:
            return CGSize(width: collectionView.width, height: 98)
        case .button:
            return CGSize(width: collectionView.width, height: 80)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSouce.sectionModels[section] {
        case .tags,.thumbnail:
            return  UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item =  dataSouce[indexPath.section].items[indexPath.item]
        switch item {
        case .tag(_,let viewModel):
            return collectionView.ar_sizeForCell(withIdentifier: AddProductTagCell.reuseIdentifier, indexPath: indexPath, fixedHeight: 25) { (cell) in
                let cell = cell  as? AddProductTagCell
                cell?.bind(to: viewModel)
                
            }
        case .thumbnail:
            return CGSize(width: 100, height: 100)
        }
    }
    
}


