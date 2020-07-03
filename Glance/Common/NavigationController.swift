//
//  NavigationController.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit
import HBDNavigationBar

class NavigationController: HBDNavigationController  {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return globalStatusBarStyle.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        
        
        
        // Do any additional setup after loading the view.
        interactivePopGestureRecognizer?.delegate = nil // Enable default iOS back swipe gesture
        
        if #available(iOS 13.0, *) {
            hero.isEnabled = false
        } else {
            hero.isEnabled = true
        }
        hero.modalAnimationType = .autoReverse(presenting: .fade)
        hero.navigationAnimationType = .autoReverse(presenting: .slide(direction: .left))
        
        
        
//        if #available(iOS 13.0, *) {
//            let standardAppearance = self.navigationBar.standardAppearance.copy()
//            standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.text(), NSAttributedString.Key.font : UIFont.titleFont(18)]
//            standardAppearance.tint
//            navigationBar.standardAppearance = standardAppearance
//
//        } else {
//
//            navigationBar.backIndicatorImage = R.image.icon_navigation_back_black()
//            navigationBar.backIndicatorTransitionMaskImage = R.image.icon_navigation_back_black()
//
//            themeService.rx
//                .bind({ $0.global }, to: navigationBar.rx.tintColor)
//                .bind({ $0.global }, to: navigationBar.rx.barTintColor)
//                .bind({ [NSAttributedString.Key.foregroundColor: $0.text, NSAttributedString.Key.font : UIFont.titleFont(18)] }, to: navigationBar.rx.titleTextAttributes)
//                .disposed(by: rx.disposeBag)
//        }
        
        
        

        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.children.count >= 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    
    
}
