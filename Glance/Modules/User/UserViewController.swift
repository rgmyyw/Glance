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
    
    private let headerRefreshTrigger = PublishSubject<Void>()
    private let isHeaderLoading = PublishSubject<Bool>()
    private lazy var userHeadView : UserHeadView = UserHeadView.loadFromNib(height: 200, width: self.view.width)

    
    private lazy var insight : UIButton = {
        let insight = UIButton()
        insight.setImage(R.image.icon_navigation_insight(), for: .normal)
        insight.sizeToFit()
        return insight
    }()
    
    private lazy var share : UIButton = {
        let share  = UIButton()
        share.setImage(R.image.icon_navigation_share(), for: .normal)
        share.sizeToFit()
        return share
    }()
    
    private lazy var setting : UIButton = {
        let setting  = UIButton()
        setting.setImage(R.image.icon_navigation_setting(), for: .normal)
        setting.sizeToFit()
        return setting
    }()
    
    private lazy var containerController : WMZPageController = {
        let container = WMZPageController()
        container.param = setupPageViewConfig(provider: viewModel!.provider)
        container.downSc.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })

        return container
    }()
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.leftBarButtonItem = insight
        navigationBar.rightBarButtonItems = [setting,share]
        stackView.addArrangedSubview(containerController.view)
        addChild(containerController)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        
        let refresh = Observable.just(()).merge(with: headerRefreshTrigger.asObservable())
        guard let viewModel = viewModel as? UserViewModel else { return }
        let input = UserViewModel.Input(headerRefresh: refresh,
                                        insight: insight.rx.tap.asObservable(),
                                        setting: setting.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
                
        
        isHeaderLoading.bind(to: containerController.downSc.headRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)

        output.displayName.drive(userHeadView.displayNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.countryName.drive(userHeadView.countryButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.userHeadImageURL.drive(userHeadView.userHeadImageView.rx.imageURL).disposed(by: rx.disposeBag)
        
        output.instagram.drive(userHeadView.instagramButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.website.drive(userHeadView.websiteButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.bio.drive(userHeadView.bioLabel.rx.text).disposed(by: rx.disposeBag)
        output.instagram.map { $0.isEmpty }.drive(userHeadView.instagramCell.rx.isHidden).disposed(by: rx.disposeBag)
        output.website.map { $0.isEmpty }.drive(userHeadView.websiteCell.rx.isHidden).disposed(by: rx.disposeBag)
        output.bio.map { $0.isEmpty }.drive(userHeadView.bioCell.rx.isHidden).disposed(by: rx.disposeBag)
        
        
        output.insight.drive(onNext: { [weak self]() in
            let viewModel = InsightsViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .insights(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
            
        output.setting.drive(onNext: { [weak self] () in
            guard let self = self else { return }
            let settingViewModel = SettingViewModel(provider: viewModel.provider)
            settingViewModel.selectedItem.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind(to: viewModel.settingSelectedItem).disposed(by: self.rx.disposeBag)
            let setting = SettingViewController(viewModel: settingViewModel, navigator: self.navigator)
            let config = CWLateralSlideConfiguration.default()
            setting.view.backgroundColor = .white
            config?.direction = .fromRight
            config?.showAnimDuration = 0.25
            self.cw_showDrawerViewController(setting, animationType: .mask, configuration: config)
        }).disposed(by: rx.disposeBag)
            
        
        
        output.updateHeadLayout.drive(onNext: { [weak self]() in
                guard let self = self else { return }
                self.userHeadView.layoutIfNeeded()
                self.userHeadView.snp.updateConstraints { (make) in
                    make.width.equalTo(self.view.width)
                    make.height.equalTo(self.userHeadView.contentView.frame.maxY)
                }
                self.userHeadView.setNeedsLayout()
                self.userHeadView.layoutIfNeeded()
                self.containerController.updateHeadView()
            }).disposed(by: rx.disposeBag)
        
        output.titles.drive(onNext: {[weak self] (titles) in
            self?.containerController.param.wTitleArr = titles
            self?.containerController.update()
        }).disposed(by: rx.disposeBag)
        
        output.about.subscribe(onNext: { () in
            
        }).disposed(by: rx.disposeBag)
                
        
        output.modifyProfile.subscribe(onNext: { [weak self]() in
            let viewModel = ModifyProfileViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .modifyProfile(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
        
        output.notifications.subscribe(onNext: { [weak self]() in
            let viewModel = NotificationProfileViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .notificationProfile(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.originalPhotos.subscribe(onNext: { [weak self]() in
            let viewModel = OriginalPhotosViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .originalPhotos(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.privacy.subscribe(onNext: { [weak self]() in
            let viewModel = PrivacyViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .privacy(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)

        output.signIn.subscribe(onNext: { () in
            guard let window = Application.shared.window else { return }
            Application.shared.showSignIn(provider: viewModel.provider, window: window)
        }).disposed(by: rx.disposeBag)

    }
    
    
    
    
}


extension UserViewController {
    
    fileprivate func setupPageViewConfig(provider : API) -> WMZPageParam {
        
        let vcs = [UserPostViewController(viewModel: UserPostViewModel(provider: provider), navigator: navigator),
                   UserRecommViewController(viewModel: UserRecommViewModel(provider: provider), navigator: navigator),
                   UserRelationViewController(viewModel: UserRelationViewModel(provider: provider, type: .followers), navigator: navigator,tableView: .grouped),
                   UserRelationViewController(viewModel: UserRelationViewModel(provider: provider, type: .following), navigator: navigator,tableView: .grouped)
        ]
        
        let config = PageParam()
        config.wTitleArr = ["0\nPosts","0\nRecomm","0\nFollowers","0\nFollowing"]
        config.wControllers = vcs
        config.wTopSuspension = true
        config.wBounces = true
        config.wFromNavi =  true
        config.wMenuAnimal = .init(3)
        config.wMenuAnimalTitleGradient = false
        config.wMenuTitleWidth = view.width / config.wTitleArr.count.cgFloat
        config.wMenuTitleWeight = 44
        config.wMenuTitleColor = UIColor(hex: 0x999999)!
        config.titleHeight = 44
        config.wMenuIndicatorColor = UIColor.primary()
        config.wMenuIndicatorWidth = 0
        config.wMenuIndicatorHeight = 2
        
        
        config.wMenuHeadView = { [weak self] in return self?.userHeadView ?? UIView() }
        config.wCustomMenuTitle = { titleButtons in
            guard let buttons = titleButtons as? [WMZPageNaviBtn] else { return }
            buttons.forEach {
                let title = $0.titleLabel?.text ?? ""
                let normaltitle = NSMutableAttributedString(string: title,attributes: [.foregroundColor: config.wMenuTitleColor,.font : UIFont.titleFont(12)])
                let selectedTitle = NSMutableAttributedString(string: title,attributes: [.foregroundColor: config.wMenuTitleColor,.font : UIFont.titleFont(12)])
                let titleList = title.components(separatedBy: "\n")
                normaltitle.addAttributes([.font : UIFont.titleFont(17)], range: title.nsString.range(of: titleList[0]))
                selectedTitle.addAttributes([.font : UIFont.titleBoldFont(17)], range: title.nsString.range(of: titleList[0]))
                
                $0.setAttributedTitle(normaltitle, for: .normal)
                $0.setAttributedTitle(selectedTitle, for: .selected)
            }
        }
        return config
    }
    
}

