//
//  Configs.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit

enum Keys {
    case wechat

    var apiKey: String {
        switch self {
        case .wechat: return ""
        }
    }

    var appId: String {
        switch self {
        case .wechat: return ""
        }
    }
}

struct Configs {

    struct App {
        
//        static let url = "http://47.115.28.73:9051"
        static let url = "http://172.16.5.162:8088"
        static let bundleIdentifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
    }

    struct Network {
        static let loggingEnabled = false
        static let url = App.url
        static let payURL = "http://172.16.8.41:9091"
    }

    struct BaseDimensions {
        static let inset: CGFloat = 12
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
        static let firstLaunch = "app_first_launch"
    }
}
