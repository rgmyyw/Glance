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
    
    fileprivate var imageViews : [StyleBoardEditView] = []
    
    fileprivate lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("NEXT", for: .normal)
        button.setTitleColor(UIColor.primary(), for: .normal)
        button.setTitleColor(UIColor.textGray(), for: .disabled)
        button.isEnabled = false
        button.titleLabel?.font = UIFont.titleFont(15)
        return button
    }()
    
    fileprivate lazy var redoButton : UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_button_redo_disable(), for: .disabled)
        button.setImage(R.image.icon_button_redo_normal(), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    fileprivate lazy var undoButton : UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_button_undo_disable(), for: .disabled)
        button.setImage(R.image.icon_button_undo_normal(), for: .normal)
        button.isEnabled = true
        return button
    }()
    
    fileprivate lazy var postProduct : PostProductViewController = {
        let viewModel = PostProductViewModel(provider: self.viewModel!.provider, image: nil,taggedItems: [])
        let controller  = PostProductViewController(viewModel: viewModel, navigator: navigator)
        return controller
    }()

    
    let selection = PublishSubject<StyleBoardEditView>()
    
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
            } else {
                imageViews.forEach { $0.showEditingHandlers = false}
            }
        }
    }
    
    
    override func makeUI() {
        super.makeUI()
        
        stackView.addArrangedSubview(contentStackView)
        collectionView.register(StyleBoardImageCell.nib, forCellWithReuseIdentifier: StyleBoardImageCell.reuseIdentifier)
        
        
        navigationBar.addSubview(undoButton)
        navigationBar.addSubview(redoButton)
        undoButton.snp.makeConstraints { (make) in
            make.right.equalTo(navigationBar.snp.centerX).offset(-20)
            make.bottom.equalTo(navigationBar.snp.bottom).offset(-10)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        redoButton.snp.makeConstraints { (make) in
            make.left.equalTo(navigationBar.snp.centerX).offset(20)
            make.centerY.equalTo(undoButton.snp.centerY)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: collectionView.height, height: collectionView.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.collectionViewLayout = layout
        
        backButton.setImage(R.image.icon_navigation_close(), for: .normal)
        navigationBar.rightBarButtonItem = nextButton
        
        containerView.rx.tap().subscribe(onNext: { [weak self]() in
            self?.selectedEditView?.showEditingHandlers = true
        }).disposed(by: rx.disposeBag)
        
        containerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
    }
    
    
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        
        
        guard let viewModel = viewModel as? StyleBoardViewModel else { return }
        
        let selected = selection.map { $0.viewModel }.filterNil().merge(with: collectionView.rx.modelSelected(StyleBoardSectionItem.self)
            .map { $0.viewModel }.asObservable())
        let input = StyleBoardViewModel.Input(next: nextButton.rx.tap.asObservable(), selection: selected)
        let output = viewModel.transform(input: input)
        
        // 提前绑定, 重复绑定会出发多次
        (self.postProduct.viewModel as? PostProductViewModel)?.reselection
            .bind(to: viewModel.reselection).disposed(by: rx.disposeBag)

        output.nextButtonEnable.drive(nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        
        output.items.map { $0.first?.items.compactMap { $0.viewModel }.filter { $0.item.productId != "" }}
            .filterNil().delay(RxTimeInterval.milliseconds(100))
            .drive(onNext: {[weak self] items in
                let productIds = items.compactMap { $0.item.productId }
                let elements = self?.imageViews.map { $0 }
                if let elements = elements , elements.isNotEmpty {
                    elements.enumerated().map { ($0, $1)}.forEach { (offset,view) in
                        if let productId = view.viewModel?.item.productId,!productIds.contains(productId) {
                            print("will remove : \(productId)")
                            let index = self?.imageViews.firstIndex {
                                $0.viewModel?.item.productId == view.viewModel?.item.productId
                            }
                            if let index = index {
                                view.viewModel = nil
                                UIView.animate(withDuration: 0.5, animations: {
                                    view.alpha = 0
                                }) { (_) in
                                    view.removeFromSuperview()
                                    self?.imageViews.remove(at: index)
                                    print("removed : \(productId)")
                                }
                            }
                        }
                    }
                }

                items.forEach { self?.addImageView(viewModel: $0) }
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            }).disposed(by: rx.disposeBag)
        
        output.post.drive(onNext: { [weak self](image, items) in
            guard let self = self else { return }
            let postProductViewModel = self.postProduct.viewModel as? PostProductViewModel
            postProductViewModel?.image.accept(image)
            postProductViewModel?.element.accept(items)
            self.navigationController?.pushViewController(self.postProduct)
        }).disposed(by: rx.disposeBag)

        output.selection.drive(onNext: {[weak self] (viewModel) in
            let view = self?.imageViews.filter { $0.viewModel?.item == viewModel.item }.first
            self?.selectedEditView = view
        }).disposed(by: rx.disposeBag)
        
        output.generateImage
            .drive(onNext: { [weak self] () in
                self?.selectedEditView = nil
                guard let image = self?.containerView.renderAsImage() else { return }
                viewModel.image.onNext(image)
        }).disposed(by: rx.disposeBag)
        
        output.add.drive(onNext: { [weak self]() in
            guard let self = self else { return }
            let styleBoardSearch = StyleBoardSearchViewModel(provider: viewModel.provider)
            styleBoardSearch.selection.bind(to: viewModel.selection).disposed(by: self.rx.disposeBag)
            self.navigator.show(segue: .styleBoardSearch(viewModel: styleBoardSearch), sender: self)
        }).disposed(by: rx.disposeBag)

    }
    
    func addImageView(viewModel : StyleBoardImageCellViewModel) {
        
        let element = imageViews.filter { $0.viewModel?.item == viewModel.item }.first
        let contains = imageViews.map { $0.viewModel?.item.productId }.contains(viewModel.item.productId)
        if contains , let element = element {
            element.viewModel = viewModel
            let index = imageViews.firstIndex { $0.viewModel?.item.productId == viewModel.item.productId }
            if let index = index {
                imageViews.remove(at: index)
                imageViews.append(element)
            } else {
                fatalError()
            }
            return
        }
        
        // 随机放在某个位置
        let x = CGFloat.random(in: 20..<(containerView.width * 0.5))
        let y = CGFloat.random(in: 20..<(containerView.width * 0.5))
         
        let point = CGPoint(x: x, y: y)
        let imageView = UIImageView(frame: CGRect(origin: point, size: viewModel.size))
        let contentView = StyleBoardEditView(contentView: imageView)
        contentView.setImage(R.image.icon_button_circular_close()!, forHandler: .close)
        contentView.setImage(R.image.icon_button_circular_rotate()!, forHandler: .rotate)
        contentView.setImage(R.image.icon_button_circular_flip()!, forHandler: .flip)
        contentView.setImage(R.image.icon_button_circular_edit()!, forHandler: .edit)
        contentView.showEditingHandlers = false
        contentView.outlineBorderColor = UIColor(hex:0xEEEEEE)!
        contentView.outlineBorderWidth = 1
        contentView.delegate = self
        contentView.setHandlerSize(18)
        contentView.viewModel = viewModel
        imageViews.append(contentView)
        containerView.addSubview(contentView)
    }
    
    
}
extension StyleBoardViewController {
    
    fileprivate func configureDataSouce() -> RxCollectionViewSectionedAnimatedDataSource<StyleBoardSection> {
        return RxCollectionViewSectionedAnimatedDataSource<StyleBoardSection>(configureCell : { (dataSouce, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .image(let viewModel):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: StyleBoardImageCell.self)
                cell.bind(to: viewModel)
                return cell
            }
        })
    }
}

extension StyleBoardViewController : StyleBoardEditViewDelegate {
    
    func styleBoardEditViewDidBeginMoving(_ editView: StyleBoardEditView) {
        selection.onNext(editView)
    }
    func styleBoardEditViewDidTap(_ editView: StyleBoardEditView) {
        selection.onNext(editView)
    }
}

