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
    
    fileprivate var imageViews : [(view : StyleBoardEditView , viewModel : StyleBoardImageCellViewModel)] = []
    
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
        let input = StyleBoardViewModel.Input(next: nextButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        output.nextButtonEnable.drive(nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        output.items.drive(collectionView.rx.items(dataSource: dataSouce)).disposed(by: rx.disposeBag)
        output.items.map { $0.first?.items.compactMap { $0.viewModel }.filter { $0.item.productId != "-1" }}
            .filterNil()
            .drive(onNext: {[weak self] items in
                
                let productIds = items.compactMap { $0.item.productId }
                let elements = self?.imageViews.map { $0 }
                if let elements = elements , elements.isNotEmpty {
                    elements.enumerated().map { ($0, $1.0, $1.1)}.forEach { (offset,view, vm) in
                        if let productId = vm.item.productId,!productIds.contains(productId) {
                            print("will remove : \(productId)")
                            let index = self?.imageViews.firstIndex { $1.item.productId == vm.item.productId }
                            if let index = index {
                                print("removed : \(productId)")
                                view.viewModel = nil
                                view.removeFromSuperview()
                                self?.imageViews.remove(at: index)
                            } else {
                                fatalError()
                            }
                        }
                    }
                }
                //print("current productIds:\(productIds)")
                //print("imageView productId:\(imageViews.map { $0.viewModel.item.productId })")
//                print("filter complete:\(elements.compactMap { $0.viewModel.item.productId })")
                items.forEach { self?.addImageView(viewModel: $0) }
                
            }).disposed(by: rx.disposeBag)
        
        
//        // 提前绑定, 重复绑定会出发多次
//        (self.postProduct.viewModel as? PostProductViewModel)?.edit
//            .bind(to: viewModel.selection).disposed(by: rx.disposeBag)
        
        output.post.drive(onNext: { [weak self](image) in
//            guard let self = self else { return }
//            let postProductViewModel = self.postProduct.viewModel as? PostProductViewModel
//            postProductViewModel?.image.accept(image)
//            postProductViewModel?.element.accept(items)
//            self.navigationController?.pushViewController(self.postProduct)
        }).disposed(by: rx.disposeBag)

        
        
        output.generateImage
            .drive(onNext: { [weak self] () in
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
        
        let contains = imageViews.map { $0.viewModel.item.productId }.contains(viewModel.item.productId)
        let element = imageViews.filter { $0.viewModel.item == viewModel.item }.first
        
        if contains , let element = element {
            element.view.viewModel = viewModel
            let index = imageViews.firstIndex { $1.item.productId == viewModel.item.productId }
            if let index = index {
                imageViews.remove(at: index)
                imageViews.append(element)
            } else {
                fatalError()
            }
            return
        }
        
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
        imageViews.append((contentView, viewModel))
        containerView.addSubview(contentView)
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

