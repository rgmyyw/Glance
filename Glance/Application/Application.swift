//
//  Application.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift


/// 配置变更通知
let configurationDidChange = PublishSubject<Void>()


final class Application: NSObject {
    static let shared = Application()

    var window: UIWindow?

    var provider: API?
    let authManager: AuthManager
    let navigator: Navigator

    private override init() {
        authManager = AuthManager.shared
        navigator = Navigator.default
        super.init()
        updateProvider()
    }

    private func updateProvider() {
        
        let ibexProvider = IbexNetworking.ibexNetworking()
        let restApi = RestApi(ibexProvider: ibexProvider)
        provider = restApi
    }

    func presentInitialScreen(in window: UIWindow?) {
        updateProvider()
        guard let window = window, let provider = provider else { return }
        self.window = window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            let viewModel = DemoViewModel(provider : provider)
//            self.navigator.show(segue: .demo(viewModel: viewModel), sender: nil, transition: .root(in: window))
            let viewModel = HomeTabBarViewModel(provider: provider)
            self.navigator.show(segue: .tabs(viewModel: viewModel), sender: nil, transition: .root(in: window))
        }
    }
    
    func logout() {
        User.removeCurrentUser()
        AuthManager.removeToken()
        Application.shared.presentInitialScreen(in: Application.shared.window)
    }
    
    
    func presentTestScreen(in window: UIWindow?) {
        guard let window = window, let provider = provider else { return }
    }

}
