//
//  User.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
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
    var website: String?
    var followerCount: Int = 0
    var countryName: String?
    var instagram: String?
    var loginStatus: Bool = false
    var postCount: Int = 0
    var recommendCount: Int = 0
    var isFollow: Bool = false
    var username: String?
    var displayName: String?
    var followingCount: Int = 0
    var userId: String?
    var bio: String?
    var userImage: String?
    var reaction: ReactionType?
    
    var isBlocked: Bool = false
    var igHandler: String?
    
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        website   <- map["website"]
        followerCount   <- map["followerCount"]
        countryName   <- map["countryName"]
        instagram   <- map["instagram"]
        loginStatus   <- map["loginStatus"]
        postCount   <- map["postCount"]
        recommendCount   <- map["recommendCount"]
        isFollow   <- map["isFollow"]
        username   <- map["username"]
        displayName   <- map["displayName"]
        followingCount   <- map["followingCount"]
        userId   <- map["userId"]
        bio   <- map["bio"]
        userImage   <- map["userImage"]
        reaction   <- map["reaction"]
        igHandler <- map["igHandler"]
        isBlocked <- map["isBlocked"]
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


extension User : Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {        
        guard let lUserId = lhs.userId,let rUserId = rhs.userId else { return false }
        return lUserId == rUserId
    }

}
