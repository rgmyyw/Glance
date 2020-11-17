//
//  Configs.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

enum Keys {

    struct Instagram  {
        static let kIssuer = "https://glance-dev-api.belive.sg/auth/realms/glance"
        static let kClientID = "glance-app"
        static let kRedirectURI = "com.glance.auth:/oauth2redirect"
    }
    
    struct Onesignal {
        static let appId = "3266c49d-8639-4aa8-b7fd-acf1f6dd714e"
    }
}

struct Configs {
    
    struct App {
        #if DEVELOP
        static let url = "http://glance:glance@192.168.1.218:8090"
        #elseif FAST_TEST
        static let url = "http://18.139.208.252:8099"
        #elseif PREVIEW
        static let url = "http://18.139.208.252:8099"
        #elseif RELEASE
        //static let url = "http://54.255.236.62:8099"
        static let url = "http://18.139.208.252:8099"
        #endif
        static let bundleIdentifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
    }
    
    struct Network {
        static let loggingEnabled = false
        static let url = App.url
    }
    
    struct BaseDimensions {
        static let inset: CGFloat = 20
        static let tabBarHeight: CGFloat = 58
        static let toolBarHeight: CGFloat = 66
        static let navBarWithStatusBarHeight: CGFloat = BaseDimensions.statusBarHeight + 44
        static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = UIScreen.main.scale * 1.0
        static let buttonHeight: CGFloat = 52
        static let textFieldHeight: CGFloat = 50
        static let tableRowHeight: CGFloat = 50
        static let segmentedControlHeight: CGFloat = 36
        static let isIPhoneX : Bool = BaseDimensions.statusBarHeight == 44 ? true : false
        static let bottomSafeArea : CGFloat = BaseDimensions.isIPhoneX ? (UIScreen.main.bounds.width < UIScreen.main.bounds.height  ? 34 : 21) : 0
    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct UserDefaultsKeys {
        static let firstLaunch = "hasBeenLaunched"
        static let disableConstraintLog =  "_UIConstraintBasedLayoutLogUnsatisfiable"
    }
}
