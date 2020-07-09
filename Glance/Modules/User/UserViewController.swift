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
    }
    
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? UserViewModel else { return }
        let input = UserViewModel.Input()
        let output = viewModel.transform(input: input)
        
        let pageViewContrller = UserPageController()
        pageViewContrller.provider = self.viewModel?.provider
        pageViewContrller.navigator = navigator
        stackView.addArrangedSubview(pageViewContrller.view)
        addChild(pageViewContrller)
        
        output.displayName.drive(pageViewContrller.userHeadView.displayNameLabel.rx.text).disposed(by: rx.disposeBag)
        output.countryName.drive(pageViewContrller.userHeadView.countryButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.userHeadImageURL.drive(pageViewContrller.userHeadView.userHeadImageView.rx.imageURL).disposed(by: rx.disposeBag)
        output.website.drive(pageViewContrller.userHeadView.websiteButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.instagram.drive(pageViewContrller.userHeadView.instagramButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        output.bio.drive(pageViewContrller.userHeadView.bioLabel.rx.text).disposed(by: rx.disposeBag)
        
        
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
                case .originalPhotos:
                    let viewModel = OriginalPhotosViewModel(provider: viewModel.provider)
                    self?.navigator.show(segue: .originalPhotos(viewModel: viewModel), sender: self)
                case .postsYourLiked: break
                case .privacy:
                    let viewModel = PrivacyViewModel(provider: viewModel.provider)
                    self?.navigator.show(segue: .privacy(viewModel: viewModel), sender: self)
                case .syncInstagram: break
                }
            }).disposed(by: rx.disposeBag)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        
    }
}

private class UserPageController: WMZPageController {
    
    var titleDatas = ["200\nPost","200\nRecomm","200\nFollowers","200\nFollowing"]
    
    lazy var userHeadView : UserHeadView = UserHeadView.loadFromNib(height: 200,width: self.view.width)
    
    var provider : API!
    var navigator : Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vcs = titleDatas.map { vc -> UIViewController in
            let vc = UIViewController()
            return vc
        }
        
        let param = PageParam()
        param.wTitleArr = titleDatas
        param.wControllers = vcs
        param.wTopSuspension = true
        param.wBounces = true
        param.wFromNavi =  true
        param.wMenuAnimal = .init(3)
        param.wMenuTitleWidth = view.width / titleDatas.count.cgFloat
        param.wMenuTitleWeight = 44
        param.wMenuTitleColor = UIColor(hex: 0x999999)!
        param.wMenuTitleSelectColor = UIColor(hex: 0x999999)!
        param.titleHeight = 44
        param.wCustomMenuTitle = { [weak self]titleButtons in
            guard let buttons = titleButtons as? [WMZPageNaviBtn] else { return }
            print(buttons)
            buttons.forEach {
                self?.updateTitle(by: $0)
            }
        }
        
        param.wMenuHeadView = {
            return self.userHeadView
        }
        
        self.param = param
    }
    
    func updateTitle(by button : WMZPageNaviBtn) {
        
        let title = button.titleLabel?.text ?? ""
        /// normal
        let normaltitle = NSMutableAttributedString(string: title,attributes: [.foregroundColor: param.wMenuTitleColor,.font : UIFont.titleFont(12)])
        /// selected
        let selectedTitle = NSMutableAttributedString(string: title,attributes: [.foregroundColor: param.wMenuTitleSelectColor,.font : UIFont.titleFont(12)])
        
        let titleList = title.components(separatedBy: "\n")
        normaltitle.addAttributes([.font : UIFont.titleFont(17)], range: title.nsString.range(of: titleList[0]))
        selectedTitle.addAttributes([.font : UIFont.titleBoldFont(17)], range: title.nsString.range(of: titleList[0]))
        
        button.setAttributedTitle(normaltitle, for: .normal)
        button.setAttributedTitle(selectedTitle, for: .selected)
    }
    
}




