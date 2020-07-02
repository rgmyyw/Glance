//
//  AppDelegate.swift
//  
//
//  Created by yanghai on 1/4/17.
//  Copyright © 2017 yanghai. All rights reserved.
//

import UIKit
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let libsManager = LibsManager.shared
        libsManager.setupLibs(with: window)

        if Configs.Network.useStaging == true {
            // Logout
            User.removeCurrentUser()
            AuthManager.removeToken()

            // Use Green Dark theme
            var theme = ThemeType.currentTheme()
            if theme.isDark != true {
                theme = theme.toggled()
            }
            theme = theme.withColor(color: .green)
            themeService.switch(theme)

            // Disable banners
            libsManager.bannersEnabled.accept(false)
        } else {
            connectedToInternet().skip(1).subscribe(onNext: { [weak self] (connected) in
                var style = ToastManager.shared.style
                style.backgroundColor = connected ? UIColor.Material.green: UIColor.Material.red
                let message = connected ? R.string.localizable.toastConnectionBackMessage.key.localized(): R.string.localizable.toastConnectionLostMessage.key.localized()
                let image = connected ? R.image.icon_toast_success(): R.image.icon_toast_warning()
                if let view = self?.window?.rootViewController?.view {
                    view.makeToast(message, position: .bottom, image: image, style: style)
                }
            }).disposed(by: rx.disposeBag)
        }

        // Show initial screen
        Application.shared.presentInitialScreen(in: window!)

        return true
    }
}
