//
//  SavedCollectionViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import ZLCollectionViewFlowLayout
import UICollectionView_ARDynamicHeightLayoutCell
import Popover
import XHWebImageAutoSize
import Kingfisher

class SavedCollectionViewController: CollectionViewController  {
    
    private lazy var dataSouce : RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SavedCollectionCellViewModel>> = configureDataSouce()
    
    private lazy var edit : UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_navigation_edit(), for: .normal)
        button.setTitleColor(UIColor.primary(), for: .normal)
        button.titleLabel?.font = UIFont.titleFont(15)
        button.sizeToFit()
        return button
    }()
    
    override func makeUI() {
        super.makeUI()
                    
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        collectionView.register(nibWithCellClass: SavedCollectionCell.self)
        
        navigationBar.rightBarButtonItem = edit
        var inset = navigationBar.contentInset
        inset.right = 20
        navigationBar.contentInset = inset
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.removeTarget(self, action: #selector(navigationBack), for: .touchUpInside)

    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? SavedCollectionViewModel else { return }
                
        let refresh = Observable<Void>.merge(Observable.just(()), headerRefreshTrigger)
        let input = SavedCollectionViewModel.Input(headerRefresh: refresh,
                                            footerRefresh: footerRefreshTrigger.mapToVoid(),
                                            selection: collectionView.rx.modelSelected(SavedCollectionCellViewModel.self).asObservable(),
                                            edit: edit.rx.tap.map { self.edit.isSelected } ,
                                            back: backButton.rx.tap.map { self.backButton.isSelected } )
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        output.navigationTitle.drive(navigationBar.rx.title).disposed(by: rx.disposeBag)
        output.backButtonImage.drive(backButton.rx.image(for: .normal)).disposed(by: rx.disposeBag)
        output.isEdit.drive(edit.rx.isSelected).disposed(by: rx.disposeBag)
        output.isEdit.drive(backButton.rx.isSelected).disposed(by: rx.disposeBag)
        output.editButtonTitle.drive(edit.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.editButtonImage.drive(edit.rx.image(for: .normal)).disposed(by: rx.disposeBag)
        output.back.drive(onNext: { [weak self] () in
            self?.navigator.pop(sender: self)
        }).disposed(by: rx.disposeBag)
        output.editButtonTitle.asObservable().mapToVoid()
            .merge(with: output.editButtonImage.asObservable().mapToVoid())
            .subscribe(onNext: { [weak self] in
                self?.navigationBar.layoutSubviews()
            }).disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: { (indexpATH) in
            let demo = DemoViewModel(provider: viewModel.provider)
            self.navigator.show(segue: .demo(viewModel: demo), sender: self)
        }).disposed(by: rx.disposeBag)
        
    }
}
// MARK: - DataSouce
extension SavedCollectionViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SavedCollectionCellViewModel>> {
        return RxCollectionViewSectionedReloadDataSource<SectionModel<Void,SavedCollectionCellViewModel>>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SavedCollectionCell.self)
            cell.bind(to: item)
            return cell
        })
    }
    
}

extension SavedCollectionViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
            
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2,sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset),itemInset: 15)
        return collectionView.ar_sizeForCell(withIdentifier: SavedCollectionCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) {[weak self] (cell) in
            if let viewModel = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? SavedCollectionCell
                cell?.bind(to: viewModel)
            }
        }
        
    }
}
