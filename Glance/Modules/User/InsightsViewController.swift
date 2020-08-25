//
//  InsightsViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import WMZPageController
import CWLateralSlide
import RxSwift
import RxCocoa

class InsightsViewController: ViewController {
    
    private lazy var containerController : WMZPageController = {
        let container = WMZPageController()
        return container
    }()
    
    override func makeUI() {
        super.makeUI()

        
        navigationTitle = "Insights"
        stackView.addArrangedSubview(containerController.view)
        addChild(containerController)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        
        guard let viewModel = viewModel as? InsightsViewModel else { return }
        let input = InsightsViewModel.Input()
        let output = viewModel.transform(input: input)
        containerController.param = setupPageViewConfig(viewModel: viewModel)
        
        viewModel.selected
            .subscribe(onNext: { [weak self](type , item) in
                let viewModel = InsightsDetailViewModel(provider: viewModel.provider, type: type, item: item.item)
                self?.navigator.show(segue: .insightsDetail(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
    }
    
    
}


extension InsightsViewController {
    
    fileprivate func setupPageViewConfig(viewModel: InsightsViewModel) -> WMZPageParam {
        
        let postViewModel = InsightsChildViewModel(provider: viewModel.provider, type: .post)
        let recommViewModel = InsightsChildViewModel(provider: viewModel.provider, type: .recommend)
        let post = InsightsChildViewController(viewModel: postViewModel, navigator: navigator)
        let Recomm = InsightsChildViewController(viewModel: recommViewModel, navigator: navigator)
        postViewModel.selected.bind(to: viewModel.selected).disposed(by: rx.disposeBag)
        recommViewModel.selected.bind(to: viewModel.selected).disposed(by: rx.disposeBag)
        
        let config = PageParam()
        config.wTitleArr = ["Post","Recomm"]
        config.wControllers = [post, Recomm]
        config.wTopSuspension = false
        config.wBounces = true
        config.wFromNavi =  true
        config.wMenuAnimal = .init(3)
        config.wMenuAnimalTitleGradient = false
        config.wMenuTitleWidth = view.width / config.wTitleArr.count.cgFloat
        config.wMenuIndicatorColor = UIColor.primary()
        config.wMenuIndicatorWidth = 0
        config.wMenuIndicatorHeight = 2
        config.titleHeight = 44
        config.wCustomMenuTitle = { titleButtons in
            guard let buttons = titleButtons as? [WMZPageNaviBtn] else { return }
            buttons.forEach {
                let title = $0.titleLabel?.text ?? ""
                let normaltitle = NSMutableAttributedString(string: title,attributes: [.foregroundColor: UIColor(hex:0xCCCCCC)!,.font : UIFont.titleBoldFont(15)])
                let selectedTitle = NSMutableAttributedString(string: title,attributes: [.foregroundColor: UIColor.text(),.font : UIFont.titleBoldFont(15)])
                $0.setAttributedTitle(normaltitle, for: .normal)
                $0.setAttributedTitle(selectedTitle, for: .selected)
            }
        }
        return config
    }
    
}

