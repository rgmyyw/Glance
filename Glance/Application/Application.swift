//
//  Application.swift
//  
//
//  Created by yanghai on 1/5/18.
//  Copyright © 2018 yanghai. All rights reserved.
//

import UIKit

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
        let staging = Configs.Network.useStaging
        let provider = staging ? Networking.stubbingNetworking(): Networking.defaultNetworking()
        let trendingProvider = staging ? TrendingNetworking.stubbingNetworking(): TrendingNetworking.defaultNetworking()
        let codetabsProvider = staging ? CodetabsNetworking.stubbingNetworking(): CodetabsNetworking.defaultNetworking()
        let restApi = RestApi(provider: provider, trendingProvider: trendingProvider, codetabsProvider: codetabsProvider)
        provider = restApi

        if let token = authManager.token, Configs.Network.useStaging == false {
            switch token.type() {
            case .oAuth(let token), .personal(let token):
                provider = GraphApi(restApi: restApi, token: token)
            default: break
            }
        }
    }

    func presentInitialScreen(in window: UIWindow?) {
        updateProvider()
        guard let window = window, let provider = provider else { return }
        self.window = window

//        presentTestScreen(in: window)
//        return

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let user = User.currentUser(), let login = user.login {
                analytics.identify(userId: login)
                analytics.set(.name(value: user.name ?? ""))
                analytics.set(.email(value: user.email ?? ""))
            }
            let authorized = self?.authManager.token?.isValid ?? false
            let viewModel = HomeTabBarViewModel(authorized: authorized, provider: provider)
            self?.navigator.show(segue: .tabs(viewModel: viewModel), sender: nil, transition: .root(in: window))
        }
    }

    func presentTestScreen(in window: UIWindow?) {
        guard let window = window, let provider = provider else { return }
        let viewModel = UserViewModel(user: User(), provider: provider)
        navigator.show(segue: .userDetails(viewModel: viewModel), sender: nil, transition: .root(in: window))
    }
}
