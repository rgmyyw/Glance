//
//  Configs.swift
//  
//
//  Created by yanghai on 1/4/17.
//  Copyright © 2017 yanghai. All rights reserved.
//

import UIKit

// All keys are demonstrative and used for the test.
enum Keys {
    case github, mixpanel

    var apiKey: String {
        switch self {
        case .github: return "5a39979251c0452a9476bd45c82a14d8e98c3fb3"
        case .mixpanel: return "7e428bc407e3612f6d3a4c8f50fd4643"
        }
    }

    var appId: String {
        switch self {
        case .github: return "00cbdbffb01ec72e280a"
        case .mixpanel: return ""
        }
    }
}

struct Configs {

    struct App {
        static let bundleIdentifier = "com.fwan.glance"
    }

    struct Network {
        static let useStaging = false  // set true for tests and generating screenshots with fastlane
        static let loggingEnabled = false
        static let githubBaseUrl = "http://127.0.0.1:8080"
    }

    struct BaseDimensions {
        static let inset: CGFloat = 8
        static let tabBarHeight: CGFloat = 58
        static let toolBarHeight: CGFloat = 66
        static let navBarWithStatusBarHeight: CGFloat = 64
        static let cornerRadius: CGFloat = 5
        static let borderWidth: CGFloat = 1
        static let buttonHeight: CGFloat = 40
        static let textFieldHeight: CGFloat = 40
        static let tableRowHeight: CGFloat = 36
        static let segmentedControlHeight: CGFloat = 40
    }

    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let Tmp = NSTemporaryDirectory()
    }

    struct UserDefaultsKeys {
        static let bannersEnabled = "BannersEnabled"
    }
}
