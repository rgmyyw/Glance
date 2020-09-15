//
//  HomeTabBarViewModel.swift
//  
//
//  Created by yanghai on 7/11/18.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AppAuth

public let needSignUp = PublishSubject<Void>()
let kPBLogin = "kPBLogin"


class HomeTabBarViewModel: ViewModel, ViewModelType {
    
    
    
    private var authState: OIDAuthState?
    
    struct Input {
    }
    
    struct Output {
        let tabBarItems: Driver<[HomeTabBarItem]>
        let signUp : Driver<Void>
    }
    
    override init(provider: API) {
        super.init(provider: provider)
    }
    
    let signUp = PublishSubject<SignInType>()
    
    
    func transform(input: Input) -> Output {
        
        let tabBarItems = loggedIn.map { (loggedIn) -> [HomeTabBarItem] in
            if loggedIn {
                return [.home, .notifications,.center, .chat, .mine]
            } else {
                return [.home, .notifications,.center ,.chat, .mine]
            }
        }.asDriver(onErrorJustReturn: [])
            
        
        return Output(tabBarItems: tabBarItems, signUp: needSignUp.asDriver(onErrorJustReturn: ()))
    }
    
    func viewModel(for tabBarItem: HomeTabBarItem) -> ViewModel {
        switch tabBarItem {
        case .home:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        case .notifications:
            let viewModel = NotificationViewModel(provider: provider)
            return viewModel
        case .chat:
            let viewModel = DemoViewModel(provider: provider)
            return viewModel
        case .mine:
            let viewModel = UserViewModel(provider: provider)
            return viewModel
        case .center:
            let viewModel = DemoViewModel(provider: provider)
            return viewModel
        }
    }
}

extension HomeTabBarViewModel {

//    func loadState(_ isForce: Bool = false) {
//        guard let data = UserDefaults.standard.object(forKey: "kAppAuthStateKey") as? Data else {
//            return
//        }
//
//        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
//            self.setAuthState(authState)
//
//            if let dateEnd = authState.lastTokenResponse?.accessTokenExpirationDate {
//                if isForce {
//                    refreshToken(authState)
//                } else {
//                    let dateNow = Date()
//                    if dateNow >= dateEnd {
//                        refreshToken(authState)
//                    }
//                }
//            }
//        }
//    }
//
//    func refreshToken(_ authState: OIDAuthState) {
//        authState.performAction { (accessToken, idToken, error) in
//            if let err = error {
//                print(err.localizedDescription)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPBLogin), object: nil)
//                return;
//            }
//
//            if let accessToken = accessToken {
//                print(accessToken)
//                //UserAccountManager.shared.handleAccount(accessToken: accessToken, isLogin: false)
//            } else {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPBLogin), object: nil)
//            }
//        }
//    }
}
