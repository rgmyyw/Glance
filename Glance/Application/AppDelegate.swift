//
//  AppDelegate.swift
//  
//
//  Created by yanghai on 11/18/19.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import Toast_Swift
import AppAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var window: UIWindow?
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        
        let libsManager = LibsManager.shared
        libsManager.setupLibs(with: window)
        AppearanceManager.shared.setup()
        Application.shared.presentInitialScreen(in: window)
        
        connectedToInternet().skip(1).subscribe(onNext: { [weak self] (connected) in
            var style = ToastManager.shared.style
            style.backgroundColor = connected ? UIColor.Material.green: UIColor.Material.red
            let message = connected ? R.string.localizable.toastConnectionBackMessage.key.localized(): R.string.localizable.toastConnectionLostMessage.key.localized()
            if let view = self?.window?.rootViewController?.view {
                view.makeToast(message, position: .bottom, image: nil, style: style)
            }
        }).disposed(by: rx.disposeBag)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authorizationFlow = OAuthManager.shared.currentAuthorizationFlow.value, authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            OAuthManager.shared.currentAuthorizationFlow.accept(nil)
            return true
        }
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool{
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool{
        return true
    }
    
    
}
