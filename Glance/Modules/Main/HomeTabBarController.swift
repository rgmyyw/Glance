//
//  HomeTabBarController.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController
import Localize_Swift
import RxSwift

enum HomeTabBarItem: Int {
    case home, category, cart, mine
    private func controller(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        switch self {
        case .home:
            let vc = DemoViewController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        case .category:
            let vc = DemoViewController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        case .cart:
            let vc = DemoViewController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        case .mine:
            let vc = DemoViewController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        }
    }
    
    var image_normal: UIImage? {
        switch self {
        case .home:
            return R.image.icon_tabbar_home_normal()?.withRenderingMode(.alwaysOriginal)
        case .category: return R.image.icon_tabbar_category_normal()?.withRenderingMode(.alwaysOriginal)
        case .cart: return R.image.icon_tabbar_cart_normal()?.withRenderingMode(.alwaysOriginal)
        case .mine: return R.image.icon_tabbar_mine_normal()?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    var image_selected: UIImage? {
        switch self {
        case .home: return R.image.icon_tabbar_home_selected()?.withRenderingMode(.alwaysOriginal)
        case .category: return R.image.icon_tabbar_category_selectedl()?.withRenderingMode(.alwaysOriginal)
        case .cart: return R.image.icon_tabbar_cart_selected()?.withRenderingMode(.alwaysOriginal)
        case .mine: return R.image.icon_tabbar_mine_selected()?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    
    var title: String {
        switch self {
        case .home: return R.string.localizable.tabBarHomeTitle.key.localized()
        case .category: return R.string.localizable.tabBarCategoryTitle.key.localized()
        case .cart: return R.string.localizable.tabBarShoppingCartTitle.key.localized()
        case .mine: return R.string.localizable.tabBarMineTitle.key.localized()
        }
    }
    
    var animation: RAMItemAnimation {
        var animation: RAMItemAnimation
        switch self {
        default:
            let item = CustomBounceAnimation()
            item.normalImage = image_normal
            item.selectedImage = image_selected
            item.textSelectedColor = UIColor.primary()
            animation = item
        }
        
        return animation
    }
    
    func getController(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        let vc = controller(with: viewModel, navigator: navigator)
        let item = CustomAnimatedTabBarItem(title: title, image: image_normal, tag: rawValue)
        item.selectedImage = image_selected
        item.animation = animation
        item.textColor = UIColor.text()
        vc.tabBarItem = item
        return vc
    }
}

class HomeTabBarController: RAMAnimatedTabBarController, Navigatable {
    
    var viewModel: HomeTabBarViewModel?
    var navigator: Navigator!
    
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
        
        themeService.typeStream.delay(DispatchTimeInterval.milliseconds(700), scheduler: MainScheduler.instance).subscribe(onNext: { (theme) in
            switch theme {
            case .light:
                self.changeSelectedColor(UIColor.primary(), iconSelectedColor: .clear)
            }
        }).disposed(by: rx.disposeBag)
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
    }
}
