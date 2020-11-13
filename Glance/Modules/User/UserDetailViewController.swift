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

class UserDetailViewController: ViewController {
    
    private let headerRefreshTrigger = PublishSubject<Void>()
    private let isHeaderLoading = PublishSubject<Bool>()
    private lazy var userHeadView : UserDetailHeadView = UserDetailHeadView.loadFromNib(height: 200, width: self.view.width)
    
    
    private lazy var insight : UIButton = {
        let insight = UIButton()
        insight.setImage(R.image.icon_navigation_insight(), for: .normal)
        insight.sizeToFit()
        return insight
    }()
    
    private lazy var share : UIButton = {
        let share  = UIButton()
        share.setImage(R.image.icon_button_share(), for: .normal)
        share.sizeToFit()
        return share
    }()
    
    private lazy var setting : UIButton = {
        let setting  = UIButton()
        setting.setImage(R.image.icon_navigation_setting(), for: .normal)
        setting.sizeToFit()
        return setting
    }()
    
    private lazy var more : UIButton = {
        let more  = UIButton()
        more.setImage(R.image.icon_navigation_more(), for: .normal)
        more.sizeToFit()
        return more
    }()
    
    
    lazy var memu: DropDownView = {
        let view = DropDownView(anchorView: more)
        view.dd_shadowColor = UIColor(hex:0x696969)!
        view.dd_shadowOpacity = 0.5
        view.dd_cornerRadius = 5
        view.dd_shadowOffset = CGSize(width: 0, height: 2)
        view.textFont = UIFont.titleFont(12)
        view.cellHeight = 32
        view.animationduration = 0.25
        let dd_width : CGFloat = 100
        view.dd_width = dd_width
        view.bottomOffset = CGPoint(x: -(dd_width - 15), y: more.height + 5)
        
        return view
    }()
    
    
    lazy var navigationItems = [backButton,share,more,insight, setting]
    
    var lastIndex : Int = 0
    
    private lazy var pageController : WMZPageController = {
        
        let config = PageParam()
        config.wTopSuspension = true
        config.wBounces = false
        config.wFromNavi =  true
        config.wMenuAnimal = .init(3)
        config.wMenuAnimalTitleGradient = false
        
        config.wMenuTitleColor = UIColor(hex: 0x999999)!
        config.wMenuTitleWeight = 44
        config.titleHeight = 44
        config.wMenuIndicatorColor = UIColor.primary()
        config.wMenuIndicatorWidth = 0
        config.wMenuIndicatorHeight = 2
        config.wMenuHeadView = { self.userHeadView }
        
        config.wCustomMenuTitle = { titleButtons in
            guard let buttons = titleButtons , buttons.isNotEmpty else { return }
            buttons.forEach { self.needUpdatePageTitltStyle(by: $0, config: config)}
        }
        
        let controller = WMZPageController()
        controller.param = config
        addChild(controller)
        stackView.addArrangedSubview(controller.view)
        
        return controller
    }()
    
    
    
    override func makeUI() {
        super.makeUI()
        
        automaticallyAdjustsLeftBarButtonItem = false
        navigationBar.leftBarButtonItem = insight
        navigationBar.rightBarButtonItems = [setting,share]
        
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let refresh = rx.viewWillAppear.mapToVoid().merge(with: headerRefreshTrigger.asObservable())
        guard let viewModel = viewModel as? UserDetailViewModel else { return }
        
        
        // 提前配置
        let input = UserDetailViewModel.Input(refresh: refresh,
                                        insight: insight.rx.tap.asObservable(),
                                        setting: setting.rx.tap.asObservable(),
                                        follow: userHeadView.followButton.rx.tap.asObservable(),
                                        chat: userHeadView.chatButton.rx.tap.asObservable(),
                                        memu: more.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        
        output.displayName.drive(userHeadView.displayNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.countryName.drive(userHeadView.countryButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.displayName.drive(userHeadView.otherUserDisplayNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.countryName.drive(userHeadView.otherUserCountryButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.userHeadImageURL.drive(userHeadView.userHeadImageView.rx.imageURL(withPlaceholder:R.image.icon_empty_default())).disposed(by: rx.disposeBag)
        output.instagram.drive(userHeadView.instagramButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.website.drive(userHeadView.websiteButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.bio.drive(userHeadView.bioLabel.rx.text).disposed(by: rx.disposeBag)
        output.instagram.map { $0.isEmpty }.drive(userHeadView.instagramCell.rx.isHidden).disposed(by: rx.disposeBag)
        output.website.map { $0.isEmpty }.drive(userHeadView.websiteCell.rx.isHidden).disposed(by: rx.disposeBag)
        output.bio.map { $0.isEmpty }.drive(userHeadView.bioLabel.rx.isHidden).disposed(by: rx.disposeBag)
        output.otherUserBgViewHidden.drive(userHeadView.otherUserBgView.rx.isHidden).disposed(by: rx.disposeBag)
        output.otherUserBgViewHidden.map { !$0}.drive(userHeadView.ownUserBgView.rx.isHidden).disposed(by: rx.disposeBag)
        output.followButtonImage.drive(userHeadView.followButton.rx.image(for: .normal)).disposed(by: rx.disposeBag)
        output.followButtonBackground.drive(userHeadView.followButton.rx.backgroundColor).disposed(by: rx.disposeBag)
        output.followButtonTitleColor.drive(userHeadView.followButton.rx.titleColor(for: .normal)).disposed(by: rx.disposeBag)
        output.followButtonTitle.drive(userHeadView.followButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        
        output.config.drive(onNext: { [weak self] (items) in
            let controllers = items.compactMap { $0.toScene(navigator: self?.navigator) }.compactMap { self?.navigator.get(segue: $0)}
            controllers.forEach { self?.addChild($0)}
            let titles = items.map { $0.defaultTitle }
            self?.pageController.param.wMenuTitleWidth = UIScreen.width / titles.count.cgFloat
            self?.pageController.param.wControllers = controllers
            self?.pageController.param.wTitleArr = titles
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
        
        
        
        output.navigationBarAvailable
            .subscribe(onNext: { [weak self](left,right) in
                let leftItems = left.compactMap { self?.navigationItems[$0.rawValue] }
                self?.navigationBar.leftBarButtonItems = leftItems
                let rightItems = right.compactMap { self?.navigationItems[$0.rawValue] }
                self?.navigationBar.rightBarButtonItems = rightItems
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
            self.pageController.updateHeadView()
        }).disposed(by: rx.disposeBag)
        
        
        output.titles.drive(onNext: {[weak self] (titles) in
            self?.pageController.param.wTitleArr = titles
            let items = self?.pageController.upSc.btnArr as? [Any] ?? []
            self?.pageController.param.wCustomMenuTitle(items as? [WMZPageNaviBtn])
                
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
            Application.shared.logout()
        }).disposed(by: rx.disposeBag)
        
        output.insight.drive(onNext: { [weak self]() in
            let viewModel = InsightsViewModel(provider: viewModel.provider)
            self?.navigator.show(segue: .insights(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
        
        output.memu.drive(onNext: { [weak self](items) in
            guard let self = self else { return }
            self.memu.dataSource = items.map { "  \($0.title)"}
            self.memu.show()
        }).disposed(by: rx.disposeBag)
        
        
        
    }
    
    
    
    
}


extension UserDetailViewController {
    
    
    func needUpdatePageTitltStyle(by button : UIButton, config :  WMZPageParam) {
        
        guard let titles = config.wTitleArr as? [String] else { return }
        let title = titles[button.tag]
        let normalAttr : [NSAttributedString.Key : Any] = [.foregroundColor: config.wMenuTitleColor,.font : UIFont.titleFont(12)]
        let selectedAttr : [NSAttributedString.Key : Any] = [.foregroundColor: config.wMenuTitleColor,.font : UIFont.titleFont(12)]
        let normaltitle = NSMutableAttributedString(string: title,attributes: normalAttr)
        let selectedTitle = NSMutableAttributedString(string: title,attributes: selectedAttr)
        let titleList = title.components(separatedBy: "\n")
        normaltitle.addAttributes([.font : UIFont.titleFont(17)], range: title.nsString.range(of: titleList[0]))
        selectedTitle.addAttributes([.font : UIFont.titleBoldFont(17)], range: title.nsString.range(of: titleList[0]))
        button.setAttributedTitle(normaltitle, for: .normal)
        button.setAttributedTitle(selectedTitle, for: .selected)
    }
    
}

