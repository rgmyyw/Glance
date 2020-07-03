//
//  User.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import Foundation
import ObjectMapper
import KeychainAccess
import RxSwift
import RxCocoa

private let userKey = "CurrentUserKey"
private let keychain = Keychain(service: Configs.App.bundleIdentifier)

let user = BehaviorRelay<User?>(value: nil)


struct User: Mappable {
    var id: String?
    var mobile: String?
    var regionCode: String?
    var nickName: String?
    var token: String?
    var email: String?
    var birthDate: String?
    var avatarUrl: String?
    var gender: Gender?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        
        id   <- map["id"]
        mobile   <- map["mobile"]
        regionCode   <- map["regionCode"]
        nickName   <- map["nickName"]
        token   <- map["token"]
        email   <- map["email"]
        birthDate   <- map["birthDate"]
        avatarUrl   <- map["avatarUrl"]
        gender   <- map["gender"]
    }
}


extension User {

    func save() {
        user.accept(self)
        if let json = self.toJSONString() {
            keychain[userKey] = json
            
        } else {
            logError("User can't be saved")
        }
    }

    static func currentUser() -> User? {
        if let json = keychain[userKey], let user = User(JSONString: json) {
            return user
        }
        return nil
    }

    static func removeCurrentUser() {
        keychain[userKey] = nil
        user.accept(nil)
    }
}


