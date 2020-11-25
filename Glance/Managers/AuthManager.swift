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

class AuthManager: NSObject {

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
            guard let jsonString = keychain[tokenKey] else { return nil }
            return Token(JSONString: jsonString)
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
