//
//  VisualSearchProductViewController.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
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

class VisualSearchProductViewController: CollectionViewController {
    
    private lazy var headVaiew : VisualSearchProductHeadView = VisualSearchProductHeadView.loadFromNib(height: 64)
    private lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<VisualSearchProductSection> = configureDataSouce()
    private let add = PublishSubject<Void>()
    
    lazy var emptyView : UIView = {

        let view = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "Can’t find product?Try other words or"
        titleLabel.textColor = UIColor(hex:0x999999)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.titleFont(12)
        let button = UIButton()
        let attr : [NSAttributedString.Key : Any] = [.underlineStyle: NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue),
                                                     .underlineColor: UIColor.primary(),
                                                     .font: titleLabel.font!,
                                                     .foregroundColor: UIColor.primary()]
        button.setAttributedTitle(NSAttributedString(string: "add product yourself.", attributes: attr), for: .normal)
        button.rx.tap.bind(to: add).disposed(by: self.rx.disposeBag)
        view.addSubview(titleLabel)
        view.addSubview(button)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(0)
        }
        button.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleLabel.snp.centerX)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        view.snp.makeConstraints { (make) in
            make.width.equalTo(UIScreen.width)
            make.height.equalTo(60)
        }
        return view

    }()
    
    
    override func makeUI() {
        super.makeUI()
        
        
        
        backButton.setImage(R.image.icon_navigation_close(), for: .normal)
        navigationTitle = "Search Product"
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = 20
        
        collectionView.headRefreshControl = nil
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        collectionView.register(nibWithCellClass: VisualSearchProductCell.self)
        collectionView.register(nib: VisualSearchProductReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: VisualSearchProductReusableView.self)

        stackView.insertArrangedSubview(headVaiew, at: 0)        
        
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? VisualSearchProductViewModel else { return }
        
        
        let input = VisualSearchProductViewModel.Input(search: headVaiew.searchButton.rx.tap.asObservable(),
                                                       footerRefresh: footerRefreshTrigger.mapToVoid(),
                                                       selection: collectionView.rx.modelSelected(VisualSearchProductSectionItem.self).asObservable(),
                                                       add: add.asObservable())
        
        (headVaiew.textFiled.rx.textInput <-> viewModel.textInput ).disposed(by: rx.disposeBag)
        
        dataSouce.configureSupplementaryView = configureSupplementaryView()
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        
    
        output.add.subscribe(onNext: { [weak self](box,image) in
            let viewModel = AddProductViewModel(provider: viewModel.provider, image: image, box: box)
            self?.navigator.show(segue: .addProduct(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
        viewModel.selected.mapToVoid()
//            .delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self]() in
                self?.navigator.pop(sender: self)
            }).disposed(by: rx.disposeBag)
        
    }

    override func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        return emptyView
    }

    override func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }

    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return emptyDataViewDataSource.verticalOffsetY.value
    }
    
}
// MARK: - DataSouce
extension VisualSearchProductViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<VisualSearchProductSection> {
        return RxCollectionViewSectionedAnimatedDataSource<VisualSearchProductSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: VisualSearchProductCell.self)
            cell.bind(to: item.viewModel)
            return cell
        })
    }
    fileprivate func configureSupplementaryView() -> (CollectionViewSectionedDataSource<VisualSearchProductSection>, UICollectionView, String, IndexPath) -> UICollectionReusableView {
        return {  (dataSouce, collectionView, kind, indexPath) -> UICollectionReusableView in
            
            if kind == UICollectionView.elementKindSectionFooter {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: VisualSearchProductReusableView.self, for: indexPath)
                view.bind(to: dataSouce[indexPath.section].viewModel)
                return view
            } else {
                
            }
            fatalError()
        }
    }


}

extension VisualSearchProductViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, typeOfLayout section: Int) -> ZLLayoutType {
        return ColumnLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, columnCountOfSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2,sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset),itemInset: 15)
        return collectionView.ar_sizeForCell(withIdentifier: VisualSearchProductCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) {[weak self] (cell) in
            if let item = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? VisualSearchProductCell
                cell?.bind(to: item.viewModel)
                cell?.setNeedsLayout()
                cell?.needsUpdateConstraints()
            }
        }
        
    }
    
    
}
 
