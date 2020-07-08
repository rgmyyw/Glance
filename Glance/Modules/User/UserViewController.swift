//
//  UserViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/7.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import WMZPageController
import CWLateralSlide
import RxSwift
import RxCocoa


class UserViewController: ViewController {
    
    lazy var insight : UIButton = {
        let insight = UIButton()
        insight.setImage(R.image.icon_navigation_insight(), for: .normal)
        insight.sizeToFit()
        return insight
    }()
    
    lazy var share : UIButton = {
        let share  = UIButton()
        share.setImage(R.image.icon_navigation_share(), for: .normal)
        share.sizeToFit()
        return share
    }()
    
    lazy var setting : UIButton = {
        let setting  = UIButton()
        setting.setImage(R.image.icon_navigation_setting(), for: .normal)
        setting.sizeToFit()
        return setting
    }()
    
    
    
    override func makeUI() {
        super.makeUI()
        

        navigationBar.leftBarButtonItem = insight
        navigationBar.rightBarButtonItems = [setting,share]


        let pageViewContrller = UserPageController()
        stackView.addArrangedSubview(pageViewContrller.view)
        addChild(pageViewContrller)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? UserViewModel else { return }
        let input = UserViewModel.Input()
        
        setting.rx.tap.subscribe(onNext: { [weak self] () in
            guard let self = self else { return }
            let settingViewModel = SettingViewModel(provider: viewModel.provider)
            settingViewModel.selectedItem.bind(to: viewModel.settingSelectedItem).disposed(by: self.rx.disposeBag)
            let setting = SettingViewController(viewModel: settingViewModel, navigator: self.navigator)
            let config = CWLateralSlideConfiguration.default()
            setting.view.backgroundColor = .white
            config?.direction = .fromRight
            config?.showAnimDuration = 0.25
            self.cw_showDrawerViewController(setting, animationType: .mask, configuration: config)
            
//            self.navigationController?.pushViewController(setting)
            
        }).disposed(by: rx.disposeBag)
        
        viewModel.settingSelectedItem
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self](item) in
                switch item {
                case .about: break
                case .followAndInviteFriends: break
                case .help: break
                case .logout: break
                case .modifyProfile:
                    let viewModel = ModifyProfileViewModel(provider: viewModel.provider)
                    self?.navigator.show(segue: .modifyProfile(viewModel: viewModel), sender: self)
                case .notifications:
                    let viewModel = NotificationProfileViewModel(provider: viewModel.provider)
                    self?.navigator.show(segue: .notificationProfile(viewModel: viewModel), sender: self)
                case .originalPhotos: break
                case .postsYourLiked: break
                case .privacy: break
                case .syncInstagram: break
                }
            }).disposed(by: rx.disposeBag)
        
        
    }
    
    
    
}

private class UserPageController: WMZPageController {
    
    var titleDatas = ["asdas","asdas","asdas","asdas","asdas"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vcs = titleDatas.map { vc -> UIViewController in
            let vc = UIViewController()
            vc.view.backgroundColor = .random
            return vc
        }
        
        let param = PageParam()
        param.wTitleArr = titleDatas
        param.wControllers = vcs
        param.wTopSuspension = true
        param.wBounces = true
        param.wFromNavi =  true
        param.wMenuHeadView = {
            let view = UIView()
            view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
            view.backgroundColor = .random
            return view
        }
        
        self.param = param
    }
    
}




