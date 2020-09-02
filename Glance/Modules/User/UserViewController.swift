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
    
    
    private lazy var containerController : WMZPageController = {
        let container = WMZPageController()
        container.param = setupPageViewConfig(provider: viewModel!.provider)
        container.downSc.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        //isHeaderLoading.bind(to: container.downSc.headRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        ///addChild(container)
        return container
    }()
    
    override func makeUI() {
        super.makeUI()
        
        automaticallyAdjustsLeftBarButtonItem = false
        navigationBar.leftBarButtonItem = insight
        navigationBar.rightBarButtonItems = [setting,share]
        stackView.addArrangedSubview(containerController.view)
        addChild(containerController)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        
        let refresh = Observable.just(()).merge(with: headerRefreshTrigger.asObservable())
        guard let viewModel = viewModel as? UserViewModel else { return }
        let input = UserViewModel.Input(refresh: refresh,
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
        output.userHeadImageURL.drive(userHeadView.userHeadImageView.rx.imageURL).disposed(by: rx.disposeBag)
        output.instagram.drive(userHeadView.instagramButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.website.drive(userHeadView.websiteButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.bio.drive(userHeadView.bioLabel.rx.text).disposed(by: rx.disposeBag)
        output.instagram.map { $0.isEmpty }.drive(userHeadView.instagramCell.rx.isHidden).disposed(by: rx.disposeBag)
        output.website.map { $0.isEmpty }.drive(userHeadView.websiteCell.rx.isHidden).disposed(by: rx.disposeBag)
        output.bio.map { $0.isEmpty }.drive(userHeadView.bioCell.rx.isHidden).disposed(by: rx.disposeBag)
        output.otherUserBgViewHidden.drive(userHeadView.otherUserBgView.rx.isHidden).disposed(by: rx.disposeBag)
        output.otherUserBgViewHidden.map { !$0}.drive(userHeadView.ownUserBgView.rx.isHidden).disposed(by: rx.disposeBag)
        output.followButtonImage.drive(userHeadView.followButton.rx.image(for: .normal)).disposed(by: rx.disposeBag)
        output.followButtonBackground.drive(userHeadView.followButton.rx.backgroundColor).disposed(by: rx.disposeBag)
        output.followButtonTitleColor.drive(userHeadView.followButton.rx.titleColor(for: .normal)).disposed(by: rx.disposeBag)
        
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
            if self.containerController.view.superview == nil {
                self.stackView.addArrangedSubview(self.containerController.view)
            }
            
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


extension UserViewController {
    
    fileprivate func setupPageViewConfig(provider : API) -> WMZPageParam {
        
        let user = (viewModel as? UserViewModel)?.current.value
        let post = UserPostViewModel(provider: provider,otherUser: user)
        let recommend = UserRecommViewModel(provider: provider,otherUser: user)
        let followers = UserRelationViewModel(provider: provider, type: .followers,otherUser: user)
        let following = UserRelationViewModel(provider: provider, type: .following,otherUser: user)
        followers.parsedError.bind(to: error).disposed(by: rx.disposeBag)
        following.parsedError.bind(to: error).disposed(by: rx.disposeBag)
        
        let vcs = [UserPostViewController(viewModel: post, navigator: navigator),
                   UserRecommViewController(viewModel: recommend, navigator: navigator),
                   UserRelationViewController(viewModel: followers, navigator: navigator,tableView: .grouped),
                   UserRelationViewController(viewModel: following, navigator: navigator,tableView: .grouped)]
        
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

