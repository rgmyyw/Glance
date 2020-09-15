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

let loggedIn = BehaviorRelay<Bool>(value: false)

class AuthManager {
    
    static let shared = AuthManager()

    // MARK: - Properties
    fileprivate let tokenKey = "TokenKey"
    fileprivate let keychain = Keychain(service: Configs.App.bundleIdentifier)
    
    let tokenChanged = PublishSubject<Token?>()

    init() {
        loggedIn.accept(hasValidToken)
        user.accept(User.currentUser())
        searchHistory.accept(SearchHistoryItem.currentAllHistory())
    }

    var token: Token? {
        get {
            #if DEVELOP
            return Token(basicToken: "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0SHpZOWZCWElOQ1d2R2xwMnp6ZkphcU5WNHhYbDc0MU9ranZURUNjb1hJIn0.eyJleHAiOjE2MDEwMTc2NDUsImlhdCI6MTU5ODQyNTY0NywiYXV0aF90aW1lIjoxNTk4NDI1NjQ1LCJqdGkiOiJiZjNhOGRjMC0zMDUwLTRkMGYtYjhlNS0xMDJkNDJlZDk3YjMiLCJpc3MiOiJodHRwczovL2dsYW5jZS1kZXYtYXBpLmJlbGl2ZS5zZy9hdXRoL3JlYWxtcy9nbGFuY2UiLCJzdWIiOiJiN2ZlMTJjNC1jM2U0LTRhNDMtYWY5Ni0xODhkZDYwM2Q0NGYiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJnbGFuY2UtYXBwIiwibm9uY2UiOiI0S01lSWhFRGp4dEkyU3g3OVZFZGIxbUZKLXktTGVrbnRqWDQ0Z2I0cG0wIiwic2Vzc2lvbl9zdGF0ZSI6IjhiNjAxNDMwLTczYjEtNDJlZS1hZjc3LTYyYjk0YjAzOWQ1ZSIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImdsYW5jZS1hcHAiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiXX19LCJzY29wZSI6Im9wZW5pZCBvZmZsaW5lX2FjY2VzcyJ9.G1GPxi3gYPajSSdAzYZMhQj8iyDJDyCLorY03IYl27EQDSBK6SiTKuA-vecZxo_HAIafl78E0nWR1HE4A6FJmy96JRtLp00IvR4sRJ9InfvWPhHuhiHOFDs32_Uz1o5wqfGwe3VjZtklEi_OZ5BGueUpebOahnZxAnCMqkUT_XS5OxRC38vQskmlIIIc4TFBI9SgJkrHaGQsfO6OZNF4NHnaDqoTRxvxYMUnbt2H5QwDWcrftgU6p1eKKafd-FWYzUnHLizJduIvl8dka2o7x-wP27SjKZaQvXC9gS9b2ndHhsH64OiXWSDxybJxxbGo7ZRUzn_3fqEAxd_50k8BlQ")
            #else
            guard let jsonString = keychain[tokenKey] else { return nil }
            return Token(JSONString: jsonString)
            #endif
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
