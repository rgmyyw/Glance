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
                return [.home, .category,.center, .cart, .mine]
            } else {
                return [.home, .category,.center ,.cart, .mine]
            }
        }.asDriver(onErrorJustReturn: [])
            
        
        signUp.subscribe(onNext: { [weak self] type in
            
            guard let issuer = URL(string: Keys.Instagram.kIssuer) else {
                self?.exceptionError.onNext(.general(message: "Error creating URL for : \(Keys.Instagram.kIssuer)"))
                return
            }
            
            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
                
                if let error = error  {
                    self?.exceptionError.onNext(.general(message: "Error retrieving discovery document: \(error.localizedDescription)"))
                    return
                }
                
                guard let configuration = configuration else {
                    self?.exceptionError.onNext(.general(message: "Error retrieving discovery document. Error & Configuration both are nil!"))
                    return
                }
                
                guard let redirectURI = URL(string: Keys.Instagram.kRedirectURI) else {
                    self?.exceptionError.onNext(.general(message: "Error creating URL for : \(Keys.Instagram.kRedirectURI)"))
                    return
                }
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    self?.exceptionError.onNext(.general(message: "Error accessing AppDelegate"))
                    return
                }
                guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                    return
                }
                
                // builds authentication request
                let request = OIDAuthorizationRequest(configuration: configuration,
                                                      clientId: Keys.Instagram.kClientID,
                                                      clientSecret: nil,
                                                      scopes: ["offline_access"],
                                                      redirectURL: redirectURI,
                                                      responseType: OIDResponseTypeCode,
                                                      additionalParameters: ["kc_idp_hint" : "instagram"])
                
                // performs authentication request
                appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: rootViewController) { (response, error) in
                    
                    if let response = response {
                        let authState = OIDAuthState(authorizationResponse: response)
                        self?.setAuthState(authState)
                        // authorization code exchange
                        guard let tokenExchangeRequest = self?.authState?.lastAuthorizationResponse.tokenExchangeRequest() else {
                            self?.exceptionError.onNext(.general(message: "Error creating authorization code exchange request"))
                            return
                        }
                        
                        print("Performing authorization code exchange with request \(tokenExchangeRequest)")
                        OIDAuthorizationService.perform(tokenExchangeRequest) { [weak self] (response, error) in
                            
                            if let tokenResponse = response {
                                let accessToken = tokenResponse.accessToken ?? ""
                                print("Received token response with accessToken: \(tokenResponse.accessToken ?? "DEFAULT_TOKEN")")
                                self?.authState?.update(with: response, error: error)
                                //UserAccountManager.shared.handleAccount(accessToken: accessToken, isLogin: true)
                                
                            } else {
                                self?.exceptionError.onNext(.general(message: "Token exchange error: \(error?.localizedDescription ?? "DEFAULT_ERROR")"))
                                self?.authState?.update(with: response, error: error)
                            }
                        }
                        
                    } else {
                        self?.exceptionError.onNext(.general(message: "Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")"))
                    }
                }
            }
        }).disposed(by: rx.disposeBag)
        
        
        return Output(tabBarItems: tabBarItems, signUp: needSignUp.asDriver(onErrorJustReturn: ()))
    }
    
    func viewModel(for tabBarItem: HomeTabBarItem) -> ViewModel {
        switch tabBarItem {
        case .home:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        case .category:
            let viewModel = NotificationViewModel(provider: provider)
            return viewModel
        case .cart:
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

extension HomeTabBarViewModel: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func stateChanged() {
        var data: Data? = nil

        if let authState = self.authState {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }

        UserDefaults.standard.set(data, forKey: "kAppAuthStateKey")
        UserDefaults.standard.synchronize()
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self
        self.stateChanged()
    }

    func loadState(_ isForce: Bool = false) {
        guard let data = UserDefaults.standard.object(forKey: "kAppAuthStateKey") as? Data else {
            return
        }
        
        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)

            if let dateEnd = authState.lastTokenResponse?.accessTokenExpirationDate {
                if isForce {
                    refreshToken(authState)
                } else {
                    let dateNow = Date()
                    if dateNow >= dateEnd {
                        refreshToken(authState)
                    }
                }
            }
        }
    }
    
    func refreshToken(_ authState: OIDAuthState) {
        authState.performAction { (accessToken, idToken, error) in
            if let err = error {
                print(err.localizedDescription)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPBLogin), object: nil)
                return;
            }
            
            if let accessToken = accessToken {
                print(accessToken)
                //UserAccountManager.shared.handleAccount(accessToken: accessToken, isLogin: false)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPBLogin), object: nil)
            }
        }
    }

    
    
    func didChange(_ state: OIDAuthState) {
        stateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        exceptionError.onNext(.general(message: "Received authorization error: \(error.localizedDescription)"))
    }

}
