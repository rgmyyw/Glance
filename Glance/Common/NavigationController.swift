//
//  NavigationController.swift
//  
//
//  Created by yanghai on 1/4/17.
//  Copyright © 2017 yanghai. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return globalStatusBarStyle.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        interactivePopGestureRecognizer?.delegate = nil // Enable default iOS back swipe gesture

        if #available(iOS 13.0, *) {
            hero.isEnabled = false
        } else {
            hero.isEnabled = true
        }
        hero.modalAnimationType = .autoReverse(presenting: .fade)
        hero.navigationAnimationType = .autoReverse(presenting: .slide(direction: .left))

        navigationBar.isTranslucent = false
        navigationBar.backIndicatorImage = R.image.icon_navigation_back()
        navigationBar.backIndicatorTransitionMaskImage = R.image.icon_navigation_back()

        themeService.rx
            .bind({ $0.secondary }, to: navigationBar.rx.tintColor)
            .bind({ $0.primaryDark }, to: navigationBar.rx.barTintColor)
            .bind({ [NSAttributedString.Key.foregroundColor: $0.text] }, to: navigationBar.rx.titleTextAttributes)
            .disposed(by: rx.disposeBag)
    }
}
