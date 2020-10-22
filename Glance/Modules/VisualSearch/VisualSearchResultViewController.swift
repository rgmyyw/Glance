//
//  VisualSearchResultViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/30.
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


class VisualSearchResultViewController: CollectionViewController  {
    
    private lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<VisualSearchResultSection> = configureDataSouce()
    
    lazy var searchButton : UIButton = {
        let searchButton = UIButton()
        searchButton.setImage(R.image.icon_navigation_search(), for: .normal)
        return searchButton
    }()

    lazy var titleLabel : UILabel = {
        let navigationTitleLabel = UILabel()
        navigationTitleLabel.text = "Visual Search"
        navigationTitleLabel.font = UIFont.titleBoldFont(18)
        navigationTitleLabel.textColor = UIColor.text()
        navigationTitleLabel.sizeToFit()

        return navigationTitleLabel
    }()
    
    lazy var descriptionLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Suggested Products"
        titleLabel.font = UIFont.titleBoldFont(15)
        titleLabel.textColor = UIColor.text()
        titleLabel.sizeToFit()
        return titleLabel
    }()

    
    lazy var descriptionView : View = {
        let view = View(height: 50)
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(20)
        }
        return view
    }()

    
    override func makeUI() {
        super.makeUI()
        
        viewDidLoadBeginRefresh = false
            
        navigationBar.bottomLineView.isHidden = false
        navigationBar.rightBarButtonItem = searchButton
        backButton.setImage(R.image.icon_navigation_close(), for: .normal)
        stackView.insertArrangedSubview(descriptionView, at: 0)

        navigationBar.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(navigationBar.snp.centerX)
            make.top.equalTo(navigationBar.snp.top).offset(10)
        }
                
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = 20
        
        
        collectionView.collectionViewLayout = layout
        collectionView.register(nibWithCellClass: VisualSearchResultCell.self)
        exceptionToastPosition = .center
        refreshComponent.accept(.footer)
        
    }
    
    override func navigationBack() {
        self.navigator.dismiss(sender: self, animated: true)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? VisualSearchResultViewModel else { return }

        let modelSelected = collectionView.rx.modelSelected(DefaultColltionSectionItem.self).asObservable()
        let search = (navigationBar.rightBarButtonItem as! UIButton).rx.tap.asObservable()
        let input = VisualSearchResultViewModel.Input(headerRefresh: headerRefreshTrigger.asObservable(),
                                                      footerRefresh: footerRefreshTrigger.mapToVoid(),
                                                      selection: modelSelected,
                                                      search: search)
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.description.drive(descriptionLabel.rx.text).disposed(by: rx.disposeBag)
        output.searchHidden.drive(searchButton.rx.isHidden).disposed(by: rx.disposeBag)
                
        output.search.subscribe(onNext: { [weak self](box, image) in
            guard let self = self else { return }
            let search = VisualSearchProductViewModel(provider: viewModel.provider, image: image, box: box)
            search.selected.bind(to: viewModel.searchSelection).disposed(by: self.rx.disposeBag)
            self.navigator.show(segue: .visualSearchProduct(viewModel: search), sender: self)
        }).disposed(by: rx.disposeBag)
        
        output.detail.drive(onNext: { [weak self](item) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
            self?.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

    }
    

    
}
// MARK: - DataSouce
extension VisualSearchResultViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<VisualSearchResultSection> {
        return RxCollectionViewSectionedAnimatedDataSource<VisualSearchResultSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: VisualSearchResultCell.self)
            cell.bind(to: item.viewModel)
            switch dataSouce[indexPath.section] {
            case .picker:
                cell.saveButton.isHidden = true
                cell.selectionButton.isHidden = false
            case .preview:
                cell.saveButton.isHidden = false
                cell.selectionButton.isHidden = true
            }
            return cell
        })
    }
    
}

extension VisualSearchResultViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
        return UIEdgeInsets(top: 10, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fixedWidth = collectionView.itemWidth(forItemsPerRow: 2,sectionInset: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset),itemInset: 15)
        return collectionView.ar_sizeForCell(withIdentifier: VisualSearchResultCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) {[weak self] (cell) in
            if let section = self?.dataSouce[indexPath.section],let item = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? VisualSearchResultCell
                cell?.bind(to: item.viewModel)
                switch section {
                case .picker:
                    cell?.saveButton.isHidden = true
                    cell?.selectionButton.isHidden = false
                case .preview:
                    cell?.saveButton.isHidden = false
                    cell?.selectionButton.isHidden = true
                }
            }
        }
        
    }
}
