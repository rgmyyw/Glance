//
//  OAuthManager.swift
//  Glance
//
//  Created by yanghai on 2020/7/21.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AppAuth

/// AppAuth key
let kIssuer = "https://glance-dev-api.belive.sg/auth/realms/glance"
let kClientID = "glance-app"
let kRedirectURI = "com.glance.auth:/oauth2redirect"
let kAppAuthStateKey = "authState";


class OAuthManager : NSObject {
    
    static let shared = OAuthManager()
    
    let state = BehaviorRelay<OIDAuthState?>(value: nil)
    let currentAuthorizationFlow = BehaviorRelay<OIDExternalUserAgentSession?>(value: nil)
    let didChange = PublishSubject<Void>()
    let update = PublishSubject<OIDAuthState>()
    let error = PublishSubject<Error>()
    let refreshToken = PublishSubject<OIDAuthState>()
    let load = PublishSubject<Bool>()
    
    
    override init() {
        super.init()
        
        
        didChange.subscribe(onNext: { [weak self] () in
            var data: Data?
            if let state = self?.state.value {
                data = NSKeyedArchiver.archivedData(withRootObject: state)
            }
            UserDefaults.standard.set(data, forKey: kAppAuthStateKey)
            UserDefaults.standard.synchronize()
        }).disposed(by: rx.disposeBag)
        
        
        update.subscribe(onNext: { [weak self] (state) in
            if let current = self?.state.value , current == state { return }
            state.stateChangeDelegate = self
            self?.state.accept(state)
            self?.didChange.onNext(())
            
        }).disposed(by: rx.disposeBag)
        
        refreshToken.subscribe(onNext: { (state) in
            state.performAction { (accessToken, idToken, error) in
                if let err = error {
                    let view = UIApplication.shared.keyWindow
                    view?.makeToast(err.localizedDescription,position: .center, title: nil,style: .init())
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPBLogin), object: nil)
                    return
                }
                
                if let accessToken = accessToken {
                    AuthManager.setToken(token: Token(basicToken: accessToken))
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPBLogin), object: nil)
                }
            }
        }).disposed(by: rx.disposeBag)
        
        load.subscribe(onNext: { [weak self] (isForce) in
            guard let data = UserDefaults.standard.object(forKey: kAppAuthStateKey) as? Data else { return }
            if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
                self?.update.onNext(authState)
                if let dateEnd = authState.lastTokenResponse?.accessTokenExpirationDate {
                    if isForce {
                        self?.refreshToken.onNext(authState)
                    } else {
                        let dateNow = Date()
                        if dateNow >= dateEnd {
                            self?.refreshToken.onNext(authState)
                        }
                    }
                }
            }
        }).disposed(by: rx.disposeBag)
        
        error.subscribe(onNext: {(error) in
            print("error: \(error.localizedDescription)")
        }).disposed(by: rx.disposeBag)
        
    }
    
}



extension OAuthManager {
    
    func instagramOAuth(presenting : UIViewController?) {
        
        let view = presenting?.view
        guard let issuer = URL(string: kIssuer) else {
            view?.makeToast("Error creating URL for : \(kIssuer)")
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { [weak self] configuration, error in
            guard let self = self else { return }
            if let error = error  {
                view?.makeToast("Error retrieving discovery document: \(error.localizedDescription)")
                return
            }
            
            guard let configuration = configuration else {
                view?.makeToast("Error retrieving discovery document. Error & Configuration both are nil!")
                return
            }
            
            guard let redirectURI = URL(string: kRedirectURI) else {
                view?.makeToast("Error creating URL for : \(kRedirectURI)")
                return
            }
            
            guard let presenting = presenting else {
                view?.makeToast("Error accessing AppDelegate")
                return
            }
            
            
            // builds authentication request
            let request = OIDAuthorizationRequest(configuration: configuration ,
                                                  clientId: kClientID,
                                                  clientSecret: nil,
                                                  scopes: ["offline_access"],
                                                  redirectURL: redirectURI,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: ["kc_idp_hint" : "instagram"])
            
            // performs authentication request
            let currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: presenting) { (response, error) in
                if let response = response {
                    let state = OIDAuthState(authorizationResponse: response)
                    self.update.onNext(state)
                    
                    // print("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
                    // authorization code exchange
                    guard let tokenExchangeRequest = self.state.value?.lastAuthorizationResponse.tokenExchangeRequest() else {
                        view?.makeToast("Error creating authorization code exchange request")
                        return
                    }
                    
                    // print("Performing authorization code exchange with request \(tokenExchangeRequest)")
                    OIDAuthorizationService.perform(tokenExchangeRequest) { [weak self] (response, error) in
                        if let tokenResponse = response {
                            let accessToken = tokenResponse.accessToken ?? ""
                            //print("Received token response with accessToken: \(tokenResponse.accessToken ?? "DEFAULT_TOKEN")")
                            self?.state.value?.update(with: response, error: error)
                            AuthManager.setToken(token: Token(basicToken: accessToken))
                        } else {
                            view?.makeToast("Token exchange error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                            self?.state.value?.update(with: response, error: error)
                        }
                    }
                } else if let error = error {
                    self.error.onNext(error)
                }
            }
            self.currentAuthorizationFlow.accept(currentAuthorizationFlow)
        }
    }
}

extension OAuthManager: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        didChange.onNext(())
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        self.error.onNext(error)
    }
}
