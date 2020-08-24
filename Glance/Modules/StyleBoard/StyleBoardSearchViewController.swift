//
//  StyleBoardSearchViewController.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import ZLCollectionViewFlowLayout
import UICollectionView_ARDynamicHeightLayoutCell


class StyleBoardSearchViewController: CollectionViewController  {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var titleItems: [UIButton]!
    @IBOutlet var emptyView: UIView!
    @IBOutlet weak var uploadYourselfButton: UIButton!
        
    private let current = BehaviorRelay<SearchType>(value: .saved)
    
    private lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<StyleBoardSearchSection> = configureDataSouce()
    
    private lazy var addButton : UIButton = {
        let button = UIButton()
        button.setTitle("ADD TO BOARD", for: .normal)
        button.setTitleColor(UIColor.textGray(), for: .disabled)
        button.setTitleColor(UIColor.primary(), for: .normal)
        button.titleLabel?.font = UIFont.titleFont(15)
        button.isEnabled = false
        return button
    }()
    
    override func makeUI() {
        super.makeUI()
                
        // 返回按钮
        backButton.setImage(R.image.icon_navigation_close(), for: .normal)
        navigationTitle = "Add Products"
        navigationBar.rightBarButtonItem = addButton
        textField.addPaddingLeft(12)
        stackView.insertArrangedSubview(titleView, at: 0)
        emptyView.removeFromSuperview()
        
        let layout = ZLCollectionViewVerticalLayout()
        layout.columnCount = 2
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = 20
        
        collectionView.headRefreshControl = nil
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        collectionView.register(nibWithCellClass: StyleBoardSearchCell.self)
        
    }
    
    override func navigationBack() {
        self.navigator.dismiss(sender: self, animated: true)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? StyleBoardSearchViewModel else { return }
            
        
        let input = StyleBoardSearchViewModel.Input(footerRefresh: footerRefreshTrigger.mapToVoid(),
                                                    selection: collectionView.rx.modelSelected(StyleBoardSearchSectionItem.self).asObservable(),
                                                    add: addButton.rx.tap.asObservable(),
                                                    currentType: current)
        let output = viewModel.transform(input: input)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.delay(RxTimeInterval.milliseconds(100)).drive(onNext: { [weak self]item in
            self?.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        output.placeholder.drive(textField.rx.placeholder).disposed(by: rx.disposeBag)
        output.addButtonEnable.drive(addButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        (textField.rx.textInput <-> viewModel.textInput).disposed(by: rx.disposeBag)
        
        titleItems.tapGesture()
            .merge(with: Observable.just(2))
            .subscribe(onNext: { [weak self]index in
                let current = self?.titleItems[index]
                self?.titleItems.forEach {
                    $0.backgroundColor = .clear
                    $0.setTitleColor(UIColor.textGray(), for: .normal)
                    $0.titleLabel?.font = UIFont.titleFont(14)
                }
                current?.backgroundColor = UIColor(hex: 0xCCCCCC)
                current?.setTitleColor(UIColor.text(), for: .normal)
                current?.titleLabel?.font = UIFont.titleBoldFont(14)
                self?.textField.text = nil
                if let type = SearchType(rawValue: index) {
                    self?.current.accept(type)
                } else {
                    fatalError()
                }
        }).disposed(by: rx.disposeBag)
        
        rx.viewDidAppear.mapToVoid()
            .subscribe(onNext: { [weak self]() in
                self?.textField.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
        

        uploadYourselfButton.rx.tap
            .subscribe(onNext: { [unowned self ]() in
                Alert.showAlert(with: "Leave to list an item?",
                                 message: "Your current edits will be saved in your Profile so that you can complete your post later.",
                                 optionTitles: "Leave",
                                 cancel: "Cancel")
                    .subscribe(onNext: { index in
                        if index == 0 {
                            self.navigationController?.dismiss(animated: false) {
                                let tabbar = UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarController
                                tabbar?.selection(item: 0)
                            }
                        }
                    }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        viewModel.selection.mapToVoid()
            .subscribe(onNext: { [weak self] in
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
extension StyleBoardSearchViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<StyleBoardSearchSection> {
        return RxCollectionViewSectionedAnimatedDataSource<StyleBoardSearchSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: StyleBoardSearchCell.self)
            cell.bind(to: item.viewModel)
            return cell
        })
    }
    
}

extension StyleBoardSearchViewController : ZLCollectionViewBaseFlowLayoutDelegate {
    
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
        return collectionView.ar_sizeForCell(withIdentifier: StyleBoardSearchCell.reuseIdentifier, indexPath: indexPath, fixedWidth: fixedWidth) {[weak self] (cell) in
            if let item = self?.dataSouce.sectionModels[indexPath.section].items[indexPath.item] {
                let cell = cell  as? StyleBoardSearchCell
                cell?.bind(to: item.viewModel)
            }
        }
        
    }
}
