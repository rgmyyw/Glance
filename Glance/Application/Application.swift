//
//  Application.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift

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
        //#if DEVELOP
        #if FLASE
        presentTestScreen(in: window)
        #else
        if loggedIn.value {
            self.showTabbar(provider: provider, window: window)
        } else {
            self.showSignIn(provider: provider, window: window)
        }
        #endif
    }

    func showSignIn(provider: API, window: UIWindow) {
        let viewModel = SignInViewModel(provider: provider)
        self.navigator.show(segue: .signIn(viewModel: viewModel), sender: nil, transition: .root(in: window))
    }

    func showTabbar(provider: API, window: UIWindow) {
        let viewModel = HomeTabBarViewModel(provider: provider)
        self.navigator.show(segue: .tabs(viewModel: viewModel), sender: nil, transition: .root(in: window))
    }

    func showInterest(provider: API, window: UIWindow) {
        let viewModel = InterestViewModel(provider: provider)
        self.navigator.show(segue: .interest(viewModel: viewModel), sender: nil, transition: .root(in: window))
    }

    func logout() {
        if let root = window?.rootViewController, !(root.isKind(of: SignInViewController.self)), loggedIn.value {
            User.removeCurrentUser()
            AuthManager.removeToken()
            Application.shared.presentInitialScreen(in: Application.shared.window)
        }
    }

    func presentTestScreen(in window: UIWindow?) {
        guard let window = window, let provider = provider else { return }

        let viewModel = DemoViewModel(provider: provider)
        self.navigator.show(segue: .demo(viewModel: viewModel), sender: nil, transition: .root(in: window))

    }
}

extension Application {

    static func isFirstLaunch() -> Bool {
        let hasBeenLaunched = Configs.UserDefaultsKeys.firstLaunch
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunched)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
