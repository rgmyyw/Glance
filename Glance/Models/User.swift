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
    var loginStatus: Bool = false
    var userId: String?
    var userImage: String?
    var displayName: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        loginStatus   <- map["loginStatus"]
        userId   <- map["userId"]
        userImage   <- map["userImage"]
        displayName   <- map["displayName"]
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


