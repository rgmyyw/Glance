//
//  AuthManager.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import KeychainAccess
import ObjectMapper
import RxSwift
import RxCocoa
import AppAuth
import OneSignal

let loggedIn = BehaviorRelay<Bool>(value: false)

class AuthManager : NSObject {
    
    static let shared = AuthManager()

    // MARK: - Properties
    fileprivate let tokenKey = "TokenKey"
    fileprivate let keychain = Keychain(service: Configs.App.bundleIdentifier)
    
    let tokenChanged = PublishSubject<Token?>()

    override init() {
        super.init()
        loggedIn.accept(hasValidToken)
        user.accept(User.currentUser())
        searchHistory.accept(SearchHistoryItem.currentAllHistory())
        user.subscribe(onNext: { (user) in
            if let userId = user?.userId {
                OneSignal.setExternalUserId(userId)
            } else {
                OneSignal.removeExternalUserId()
            }
        }).disposed(by: rx.disposeBag)
    }

    var token: Token? {
        get {
//            #if DEVELOP
//            return Token(basicToken: " eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0SHpZOWZCWElOQ1d2R2xwMnp6ZkphcU5WNHhYbDc0MU9ranZURUNjb1hJIn0.eyJleHAiOjE2MTA1ODkzNjAsImlhdCI6MTYwMjgxMzM2MCwiYXV0aF90aW1lIjoxNjAyODEzMzYwLCJqdGkiOiIxYTZhN2U1ZC0wMTA1LTRiMTktYjA4My01Njc0ZTAwNTY3ZDYiLCJpc3MiOiJodHRwczovL2dsYW5jZS1kZXYtYXBpLmJlbGl2ZS5zZy9hdXRoL3JlYWxtcy9nbGFuY2UiLCJzdWIiOiI0YWM3YTc0Yy04Yzk2LTRmMzctYjc2OC0yYmI5OTkxMWZkNDQiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJnbGFuY2UtYXBwIiwibm9uY2UiOiJ6TXc0cU5hMFZmdzJ3bjEtdTZISTJPWmMzQVNXNlNfWEVoRkl0M2Zxek44Iiwic2Vzc2lvbl9zdGF0ZSI6IjAyMTE3NjQ0LWEyZDAtNDA2Mi1hM2MzLWM3YjYzZjFmOThhZSIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImdsYW5jZS1hcHAiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiXX19LCJzY29wZSI6Im9wZW5pZCBvZmZsaW5lX2FjY2VzcyJ9.P4o4Sx7dnh2GEmxANHjuIFwAU6-ABD-JC8rEz844O45CvLyVYcv-lMjsvMFpd8SSP0e4e9r-udNAc3FAAn4Xw7RSJAsT_BsOHZdP9in01MQeSESepZC-axeaJrXlST30A9ryVOZhEicL6LbgBPxvcc0eQ7k5S_B9Ryxk2UH1WGeKSZ9zj6ffHB-EO6fS1sSAdMG6x54aGNltfGGfDbiuRgJ_mv4awnTGsZJtE6iPYTR0exD5qnPKcbC6Q-UveNuWy9DE3OkCp4gI_6uxqmCuYcDN-aHRrCI25Rng5IgJ4m7f2MCYKzEtSQw26FXnUuq381QYi_Q37BXc1B40eq0oPw")
//            #else
            guard let jsonString = keychain[tokenKey] else { return nil }
            return Token(JSONString: jsonString)
//            #endif
        }
        set {
            if let token = newValue, let jsonString = token.toJSONString() {
                keychain[tokenKey] = jsonString
            } else {
                keychain[tokenKey] = nil
            }
            tokenChanged.onNext(newValue)
            loggedIn.accept(hasValidToken)
        }
    }

    var hasValidToken: Bool {
        return token?.isValid == true
    }

    class func setToken(token: Token) {
        AuthManager.shared.token = token
    }

    class func removeToken() {
        AuthManager.shared.token = nil
    }

    class func tokenValidated() {
        AuthManager.shared.token?.isValid = true
    }
}
