//
//  SearchResultViewController.swift
//  Glance
//
//  Created by yanghai on 2020/9/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WMZPageController

class SearchResultViewController: ViewController {
    
    private lazy var customNavigationBar : SearchResultNavigationBar = SearchResultNavigationBar.loadFromNib(height: 44,width: self.view.width)


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
        
        
        let refresh = Observable.just(())
        guard let viewModel = viewModel as? SearchResultViewModel else { return }

        let input = SearchResultViewModel.Input(refresh: refresh,
                                                   search: customNavigationBar.searchView.rx.tap().asObservable())
        let output = viewModel.transform(input: input)

        viewModel.text.bind(to: customNavigationBar.titleLabel.rx.text).disposed(by: rx.disposeBag)
        
        
        viewModel.text.subscribe(onNext: { (text) in
            print(text)
        }).disposed(by: rx.disposeBag)
        
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
                        make.bottom.equalTo(mainView).offset(-4)
                        make.right.equalTo(mainView)
                        make.height.equalTo(0.5)
                    }
                }
            }
        }).disposed(by: rx.disposeBag)
            
        output.search.drive(onNext: { [weak self](text) in
            let search = SearchViewModel(provider: viewModel.provider, text: text)
            search.selection.bind(to: viewModel.text).disposed(by: self!.rx.disposeBag)
            self?.navigator.show(segue: .search(viewModel: search), sender: self,transition: .modal)
        }).disposed(by: rx.disposeBag)
    }
    
}

extension SearchResultViewController {
  
    
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

