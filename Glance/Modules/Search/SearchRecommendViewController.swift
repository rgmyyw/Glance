//
//  SearchRecommendViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WMZPageController

class SearchRecommendViewController: ViewController {
    
    private lazy var customNavigationBar : SearchRecommendNavigationBar = SearchRecommendNavigationBar.loadFromNib(height: 44,width: self.view.width)
    private lazy var headView : SearchRecommendHistoryView = SearchRecommendHistoryView.loadFromNib()

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
        
        let controller = WMZPageController()
        controller.param = config
        
        addChild(controller)
        stackView.addArrangedSubview(controller.view)
        
        return controller
    }()

    
    override func makeUI() {
        super.makeUI()
        customNavigationBar.backButton.addTarget(self, action: #selector(navigationBack), for: .touchUpInside)
        navigationBar.addSubview(customNavigationBar)
    }
    
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let refresh = rx.viewWillAppear.mapToVoid()
        guard let viewModel = viewModel as? SearchRecommendViewModel else { return }

        let clearAll = headView.clearButton.rx.tap.asObservable()
        let search = customNavigationBar.searchView.rx.tap().asObservable()
        let historySelection = headView.collectionView.rx.modelSelected(SearchRecommendHistorySectionItem.self).asObservable()
        let camera = customNavigationBar.cameraButton.rx.tap.asObservable()
        
        let input = SearchRecommendViewModel.Input(refresh: refresh,
                                                   clearAll: clearAll,
                                                   search: search,
                                                   historySelection: historySelection,
                                                   camera: camera)
        let output = viewModel.transform(input: input)
        output.history.drive(headView.items).disposed(by: rx.disposeBag)

        output.config.drive(onNext: { [weak self] (items) in
            let controllers = items.compactMap { $0.toScene(navigator: self?.navigator) }.compactMap { self?.navigator.get(segue: $0)}
            controllers.forEach { self?.addChild($0)}
            let titles = items.map { $0.defaultTitle }
            self?.pageController.param.wControllers = controllers
            self?.pageController.param.wTitleArr = titles
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let line = UIView()
                line.backgroundColor = UIColor(hex: 0xF0F0F0)
                self?.pageController.upSc.backgroundColor = .white
                if let content = self?.pageController.upSc ,
                   let mainView = self?.pageController.upSc.mainView {
                    content.addSubview(line)
                    line.snp.makeConstraints { (make) in
                        make.left.equalTo(mainView).offset(-20)
                        make.bottom.equalTo(mainView).offset(-5)
                        make.right.equalTo(mainView)
                        make.height.equalTo(0.5)
                    }
                }
            }
        }).disposed(by: rx.disposeBag)
        
        output.viSearch.drive(onNext: { [weak self]() in
            ImagePickerManager.shared.showPhotoLibrary(sender: self, animate: true, configuration: { (config) in
                config.maxSelectCount = 1
                config.editAfterSelectThumbnailImage = true
                config.saveNewImageAfterEdit = false
                config.allowEditImage = false
            }) { [weak self] (images, assets, isOriginal) in
                guard let image = images?.first else { return }
                let viewModel = VisualSearchViewModel(provider: viewModel.provider, image: image)
                self?.navigator.show(segue: .visualSearch(viewModel: viewModel), sender: self,transition: .modal)
            }
        }).disposed(by: rx.disposeBag)

        
        output.headHidden.drive(onNext: { [weak self](hidden) in
            self?.pageController.param.wMenuHeadView = {
                self?.headView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.width, height: hidden ? 0.1 : 90))
                self?.headView.setNeedsLayout()
                self?.headView.layoutIfNeeded()
                return self?.headView
            }
            self?.pageController.updateHeadView()
        }).disposed(by: rx.disposeBag)
                
        output.searchResult.drive(onNext: { [weak self](text) in
            let viewModel = SearchResultViewModel(provider: viewModel.provider, text: text)
            self?.navigator.show(segue: .searchResult(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        
        output.search.drive(onNext: { [weak self]() in
            let viewModel = SearchViewModel(provider: viewModel.provider, text: "")
            self?.navigator.show(segue: .search(viewModel: viewModel), sender: self,transition: .modal)
        }).disposed(by: rx.disposeBag)
    }
    
}

extension SearchRecommendViewController {
  
    
    func needUpdatePageTitltStyle(by button : UIButton, config :  WMZPageParam) {
        
        let title = button.titleLabel?.text ?? ""
        let normalAttr : [NSAttributedString.Key : Any] = [.foregroundColor: config.wMenuTitleColor,.font : UIFont.titleBoldFont(15)]
        let selectedAttr : [NSAttributedString.Key : Any] = [.foregroundColor: config.wMenuTitleSelectColor,.font : UIFont.titleBoldFont(18)]
        let normaltitle = NSMutableAttributedString(string: title,attributes: normalAttr)
        let selectedTitle = NSMutableAttributedString(string: title,attributes: selectedAttr)
        button.setAttributedTitle(normaltitle, for: .normal)
        button.setAttributedTitle(selectedTitle, for: .selected)
    }

}

