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
    
    let currentAuthorizationFlow = BehaviorRelay<OIDExternalUserAgentSession?>(value: nil)
    
    let tokenChanged = PublishSubject<Token?>()

    init() {
        loggedIn.accept(hasValidToken)
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
    
    /// 获取到  账户信息  isLogin:是否来源于登录
//    func handleAccount(accessToken: String, isLogin: Bool) -> (){
//        
//        print("accessToken \(accessToken) , isLogin \(isLogin)")
//        guard accessToken.count > 0 else {
//            return
//        }
//        
//        
////        // 1. 更新账户token信息
////        let userInfoModel  = UserInfoSingleCase.shared
////        userInfoModel.updateTokenInfo(accessToken)
////
////        // 2. 持久化
////        if let accessToken = userInfoModel._accessToken{
////            String.PreferencesSave(key: kAccount_accessToken, valueStr: accessToken)
////            String.PreferencesSave(key: kAccount_User_login, valueStr: "1")
////        }
////
////        if isLogin { // 来源于登录
////            getUserInfoFirstly()
////        }
//    }
//
    
}
