//
//  ImageSynthesizerViewController.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ZLCollectionViewFlowLayout


class StyleBoardViewController: ViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate lazy var dataSouce : RxCollectionViewSectionedAnimatedDataSource<StyleBoardSection> = configureDataSouce()
    fileprivate lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("NEXT", for: .normal)
        button.setTitleColor(UIColor.primary(), for: .normal)
        button.titleLabel?.font = UIFont.titleFont(15)
        return button
    }()
    
    private var _selectedEditView:StyleBoardEditView?
    var selectedEditView:StyleBoardEditView? {
        get {
            return _selectedEditView
        }
        set {
            if _selectedEditView != newValue {
                if let selectedStickerView = _selectedEditView {
                    selectedStickerView.showEditingHandlers = false
                }
                _selectedEditView = newValue
            }
            
            if let selectedEditView = _selectedEditView {
                selectedEditView.showEditingHandlers = true
                selectedEditView.superview?.bringSubviewToFront(selectedEditView)
            }
        }
    }

    
    override func makeUI() {
        super.makeUI()
        
        stackView.addArrangedSubview(contentStackView)
        collectionView.register(StyleBoardImageCell.nib, forCellWithReuseIdentifier: StyleBoardImageCell.reuseIdentifier)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: collectionView.height, height: collectionView.height)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        backButton.setImage(R.image.icon_navigation_close(), for: .normal)
        navigationBar.rightBarButtonItem = nextButton
        
        containerView.rx.tap().subscribe(onNext: { [weak self]() in
            self?.selectedEditView?.showEditingHandlers = true
        }).disposed(by: rx.disposeBag)
    }
    
    
    func addImageView(item : StyleBoardImageCellViewModel) {
        if item.empty.value { return}
//        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: CGFloat.random(in: 200...500), y: CGFloat.random(in: 100...500)), size: item.size))
        let imageView = UIImageView(frame: CGRect(x: 200, y: 300, w: item.size.width, h: item.size.height))

        item.image.bind(to: imageView.rx.imageURL).disposed(by: rx.disposeBag)
        
        let contentView = StyleBoardEditView(contentView: imageView)
        contentView.setImage(R.image.icon_close()!, forHandler: .close)
        contentView.setImage(R.image.icon_button_rotate()!, forHandler: .rotate)
        contentView.setImage(R.image.icon_button_circular_edit()!, forHandler: .flip)
        contentView.setImage(R.image.icon_button_circular_edit()!, forHandler: .edit)
        contentView.showEditingHandlers = false
        contentView.outlineBorderColor = UIColor(hex:0xEEEEEE)!
        contentView.outlineBorderWidth = 2
        contentView.delegate = self
        containerView.addSubview(contentView)
    }
    
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? StyleBoardViewModel else { return }
        let input = StyleBoardViewModel.Input(next: nextButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        output.currentProducts.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.currentProducts
            .map { $0[0].items.compactMap { $0.viewModel }}
            .drive(onNext: {[weak self] items in
            for i in items {
                self?.addImageView(item: i)
            }
        }).disposed(by: rx.disposeBag)
        output.add.drive(onNext: { [weak self]() in
            guard let self = self else { return }
            let styleBoardSearch = StyleBoardSearchViewModel(provider: viewModel.provider)
            styleBoardSearch.selection.bind(to: viewModel.selection).disposed(by: self.rx.disposeBag)
            self.navigator.show(segue: .styleBoardSearch(viewModel: styleBoardSearch), sender: self)
        }).disposed(by: rx.disposeBag)
        
    }
}
extension StyleBoardViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<StyleBoardSection> {
        return RxCollectionViewSectionedAnimatedDataSource<StyleBoardSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .image(_, let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: StyleBoardImageCell.self)
                cell.bind(to: viewModel)
                return cell
            }
        })
    }
}

extension StyleBoardViewController : StyleBoardEditViewDelegate {
    
    func styleBoardEditViewDidBeginMoving(_ editView: StyleBoardEditView) {
        self.selectedEditView = editView
    }
    func styleBoardEditViewDidTap(_ editView: StyleBoardEditView) {
        self.selectedEditView = editView
    }
}
    
