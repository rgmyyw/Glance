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
import WMZPageController


class StyleBoardSearchViewController: ViewController  {
    
    private lazy var headView : StyleBoardSearchTextFieldView = StyleBoardSearchTextFieldView.loadFromNib(height: 54)

    private lazy var pageController : WMZPageController = {
            
        let config = PageParam()
        config.wTopSuspension = true
        config.wBounces = false
        config.wFromNavi =  true
        config.wMenuAnimal = PageTitleMenu.init(3)
        config.wMenuAnimalTitleGradient = true
        config.wMenuTitleColor = UIColor.textGray()
        config.wMenuTitleSelectColor = UIColor.text()
        config.wMenuTitleUIFont = UIFont.titleBoldFont(16)
        config.wMenuTitleSelectUIFont = UIFont.titleBoldFont(16)
        config.wMenuIndicatorColor = UIColor.primary()
        config.wMenuIndicatorWidth = 20
        config.wMenuIndicatorHeight = 4
        config.wMenuHeadView = { self.headView }
        config.wMenuAnimalTitleBig = true
        config.wMenuIndicatorRadio = 2
        config.wScrollCanTransfer = true
        config.wMenuCellMargin = 15
        config.wMenuWidth = UIScreen.width - 12
        config.wMenuPosition = .init(rawValue: 1)
        config.wMenuBgColor = .white
        config.wMenuDefaultIndex = 2
        
        let controller = WMZPageController()
        controller.param = config
        
        addChild(controller)
        stackView.addArrangedSubview(controller.view)
        
        return controller
    }()

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
                
        backButton.setImage(R.image.icon_navigation_close(), for: .normal)
        navigationTitle = "Add Products"
        navigationBar.rightBarButtonItem = addButton
    }

    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? StyleBoardSearchViewModel else { return }
            
        
        let add = addButton.rx.tap.asObservable()
        let input = StyleBoardSearchViewModel.Input(add: add)
        let output = viewModel.transform(input: input)
        output.placeholder.drive(headView.textField.rx.placeholder).disposed(by: rx.disposeBag)
        output.addButtonEnable.drive(addButton.rx.isEnabled).disposed(by: rx.disposeBag)
        (headView.textField.rx.textInput <-> viewModel.textInput).disposed(by: rx.disposeBag)

        output.config.drive(onNext: { [weak self] (items) in
            let controllers = items.compactMap { $0.toScene(navigator: self?.navigator) }.compactMap { self?.navigator.get(segue: $0)}
            controllers.forEach { self?.addChild($0)}
            let titles = items.map { $0.title }
            self?.pageController.param.wControllers = controllers
            self?.pageController.param.wTitleArr = titles
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.pageController.update()
                self?.pageController.upSc.backgroundColor = .white
            }

        }).disposed(by: rx.disposeBag)

        output.complete
            .drive(onNext: { [weak self]() in
                self?.navigator.pop(sender: self, toRoot: true)
        }).disposed(by: rx.disposeBag)
      
        rx.viewDidAppear.mapToVoid()
            .subscribe(onNext: { [weak self]() in
                self?.headView.textField.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
        
        output.upload.drive(onNext: { () in
            ImagePickerManager.shared.showPhotoLibrary(sender: self, animate: true, configuration: { (config) in
                config.maxSelectCount = 1
                config.editAfterSelectThumbnailImage = true
                config.saveNewImageAfterEdit = false
                config.allowEditImage = false
            }) { [weak self] (images, assets, isOriginal) in
                guard let image = images?.first else { return }
                let viewModel = AddProductViewModel(provider: viewModel.provider, image: image, mode: .styleBoard)
                self?.navigator.show(segue: .addProduct(viewModel: viewModel), sender: self,transition: .modal)
            }
        }).disposed(by: rx.disposeBag)
    }
    
}
