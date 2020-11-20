//
//  HomeTabBarController.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController
import Localize_Swift
import RxSwift
import WZLBadge

class HomeTabBarController: RAMAnimatedTabBarController, Navigatable , UITabBarControllerDelegate {
    
    var viewModel: HomeTabBarViewModel?
    var navigator: Navigator!
    let popView = PublishPopView.loadFromNib()
    let message = PublishSubject<Message>()
    
    
    init(viewModel: ViewModel?, navigator: Navigator) {
        self.viewModel = viewModel as? HomeTabBarViewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        makeUI()
        bindViewModel()
    }
    
    
    
    func makeUI() {
        // Configure tab bar
        hero.isEnabled = false
        tabBar.hero.id = "TabBarID"
        tabBar.isTranslucent = false
        delegate = self
        
        
        if #available(iOS 13, *) {
            let appearance = self.tabBar.standardAppearance.copy()
            appearance.shadowImage = UIImage(color: .clear)
            appearance.backgroundImage = UIImage(color: .white)
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            
        } else {
            tabBar.shadowImage = UIImage(color: .clear)
            tabBar.backgroundImage = UIImage(color: .white)
        }
        
        tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -5)
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowRadius = 10
        
        
        NotificationCenter.default
            .rx.notification(NSNotification.Name(LCLLanguageChangeNotification))
            .subscribe { [weak self] (event) in
                self?.animatedItems.forEach({ (item) in
                    item.title = HomeTabBarItem(rawValue: item.tag)?.title
                })
                self?.setViewControllers(self?.viewControllers, animated: false)
                self?.setSelectIndex(from: 0, to: self?.selectedIndex ?? 0)
        }.disposed(by: rx.disposeBag)
        
        themeService.rx
            .bind({ $0.global }, to: tabBar.rx.barTintColor)
            .disposed(by: rx.disposeBag)
        
        themeService.typeStream
            .delay(DispatchTimeInterval.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (theme) in
                switch theme {
                case .light:
                    self.changeSelectedColor(UIColor.primary(), iconSelectedColor: .clear)
                }
            }).disposed(by: rx.disposeBag)
        
        viewModel?.message.bind(to: message).disposed(by: rx.disposeBag)
        
        message.subscribe(onNext: {[weak self] message in
            self?.view.makeToast(message.subTitle,position: .center, title: message.title,style: message.style )
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(.kUpdateBageValue).map { (noti) -> Badge? in
            return Badge(JSON: noti.userInfo as? [String : Any] ?? [:])
        }.filterNil().subscribe(onNext: { [weak self](item) in
            self?.animatedItems[1].iconView?.icon.showBadge(value: item.notice)
        }).disposed(by: rx.disposeBag)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            PermissionManager.shared.requestPermissions()
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: DemoViewController.self) {
            popView.addAnimate()
            return false
        } else {
            return true
        }
    }
    
    
    
    func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        let input = HomeTabBarViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.tabBarItems.drive(onNext: { [weak self] (tabBarItems) in
            if let strongSelf = self {
                let controllers = tabBarItems.map { $0.getController(with: viewModel.viewModel(for: $0), navigator: strongSelf.navigator) }
                strongSelf.setViewControllers(controllers, animated: false)
            }
        }).disposed(by: rx.disposeBag)
        
        output.userDetail.drive(onNext: { [weak self](user) in
            let viewModel = UserDetailViewModel(provider: viewModel.provider, otherUser: user)
            self?.navigator.show(segue: .userDetail(viewModel: viewModel), sender: self?.topViewController())
        }).disposed(by: rx.disposeBag)
        
        output.themeDetail.drive(onNext: { [weak self](themeId) in
            let viewModel = SearchThemeViewModel(provider: viewModel.provider, themeId: themeId)
            self?.navigator.show(segue: .searchTheme(viewModel: viewModel), sender: self?.topViewController())
        }).disposed(by: rx.disposeBag)
        
        output.postDetail.drive(onNext: { [weak self](item) in
            let viewModel = PostsDetailViewModel(provider: viewModel.provider, item: item)
            self?.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self?.topViewController())
        }).disposed(by: rx.disposeBag)

        output.insightDetail.drive(onNext: { [weak self](item) in
            let viewModel = InsightsDetailViewModel(provider: viewModel.provider, type: .recommend, item: item)
            self?.navigator.show(segue: .insightsDetail(viewModel: viewModel), sender: self?.topViewController())
        }).disposed(by: rx.disposeBag)

        output.notice.drive(onNext: { [weak self]() in
            self?.topViewController()?.navigationController?.popToRootViewController(animated: false)
            self?.setSelectIndex(from: self?.selectedIndex ?? 0, to: 1)
        }).disposed(by: rx.disposeBag)
        
        output.following.drive(onNext: { [weak self]() in
            self?.topViewController()?.navigationController?.popToRootViewController(animated: false)
            self?.setSelectIndex(from: self?.selectedIndex ?? 0, to: 4)
            NotificationCenter.default.post(name: .kMineSelectionMemuIndex, object: nil, userInfo: ["index" : 2])
        }).disposed(by: rx.disposeBag)

        
        
        popView.selection.delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] item in
                self?.selection(item: item)
            }).disposed(by: rx.disposeBag)
    }
    
    func selection(item : Int) {
        
        guard let viewModel = viewModel else { return }
        
        switch item {
        case 0:
            ImagePickerManager.shared.showPhotoLibrary(sender: self, animate: true, configuration: { (config) in
                config.maxSelectCount = 1
                config.editAfterSelectThumbnailImage = true
                config.saveNewImageAfterEdit = false
                config.allowEditImage = false
            }) { [weak self] (images, assets, isOriginal) in
                
                guard let image = images?.first else { return }
                let viewModel = VisualSearchViewModel(provider: viewModel.provider, image: image,mode: .post)
                self?.navigator.show(segue: .visualSearch(viewModel: viewModel), sender: self,transition: .modal)
            }
            
        case 1:
            let styleBoard = StyleBoardViewModel(provider: viewModel.provider)
            self.navigator.show(segue: .styleBoard(viewModel: styleBoard), sender: self,transition: .modal)
        default:
            break
        }
        
    }
    
}
