//
//  LibsManager.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import IQKeyboardManagerSwift
import CocoaLumberjack
import Kingfisher
#if DEBUG
import FLEX
import CocoaDebug
#endif
import NVActivityIndicatorView
import NSObject_Rx
import RxViewController
import RxOptional
import RxGesture
import SwifterSwift
import SwiftDate
import DropDown
import Toast_Swift
import OneSignal

typealias DropDownView = DropDown

class LibsManager: NSObject  {

    static let shared = LibsManager()

    override init() {
        super.init()

    }

    func setupLibs(with window: UIWindow? = nil, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {

        UserDefaults.standard.setValue(false, forKey: Configs.UserDefaultsKeys.disableConstraintLog)

        let libsManager = LibsManager.shared
        libsManager.setupCocoaLumberjack()
        libsManager.setupTheme()
        libsManager.setupFLEX()
        libsManager.setupKeyboardManager()
        libsManager.setupActivityView()
        libsManager.setupDropDown()
        libsManager.setupToast()
        libsManager.setupPgyer()
        libsManager.setupOneSignal(launchOptions: launchOptions ?? [:])
        libsManager.setupCocoaDebug()

        OAuthManager.shared.setup()
        BadgeValueManager.shared.setup()

    }

    func setupTheme() {
        themeService.rx
            .bind({ $0.statusBarStyle }, to: UIApplication.shared.rx.statusBarStyle)
            .disposed(by: rx.disposeBag)

          var theme = ThemeType.currentTheme()

          if theme.isDark != true {
              theme = theme.toggled()
          }
          theme = theme.withColor(color: .primary)
          themeService.switch(theme)
    }

    func setupDropDown() {

        if #available(iOS 11.0, *) {
            DropDown.appearance().setupMaskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        }
        themeService.attrsStream.subscribe(onNext: { (theme) in
            DropDown.appearance().backgroundColor = .white
            DropDown.appearance().selectionBackgroundColor = UIColor.white
            DropDown.appearance().textColor = theme.text
            DropDown.appearance().selectedTextColor = theme.text
            DropDown.appearance().separatorColor = theme.separator

        }).disposed(by: rx.disposeBag)
    }

    func setupToast() {
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.position = .bottom
        ToastManager.shared.duration = 1.5
        ToastManager.shared.isQueueEnabled = true

        var style = ToastStyle()
        style.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        style.messageColor = .white
        style.messageAlignment = .center
        style.messageFont = UIFont.titleFont(16)
        style.imageSize = .zero
        style.shadowRadius = 20
        ToastManager.shared.style = style
    }

    func setupActivityView() {
        NVActivityIndicatorView.DEFAULT_TYPE = .lineScalePulseOutRapid
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor.secondary().withAlphaComponent(1)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 20, height: 20)
        NVActivityIndicatorView.DEFAULT_PADDING = 0
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor.black.withAlphaComponent(0)
    }

    func setupKeyboardManager() {

        let manager = IQKeyboardManager.shared
        manager.enable = true
        manager.shouldResignOnTouchOutside = true
        manager.shouldToolbarUsesTextFieldTintColor = true
        manager.keyboardDistanceFromTextField = 60
        manager.enableAutoToolbar = true
    }

    func setupKingfisher() {

        ImageCache.default.diskStorage.config.sizeLimit = UInt(500 * 1024 * 1024) // 500 MB
        ImageCache.default.diskStorage.config.expiration = .days(7) // 1 week
        ImageDownloader.default.downloadTimeout = 15.0 // 15 sec

    }

    func setupCocoaLumberjack() {
        if #available(iOS 10, *) {
            DDLog.add(DDOSLogger.sharedInstance) // TTY = Xcode console
        } else {
            DDLog.add(DDASLLogger.sharedInstance) // ASL = Apple System Logs
        }
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }

    func setupFLEX() {
        #if DEBUG
        FLEXManager.shared.isNetworkDebuggingEnabled = true
        #endif
    }

    func setupPgyer() {
//        PgyManager.shared()?.start(withAppId: "322e4c9240c6f00d596aa436014eb63a")
//
//        #if DEBUG
//        PgyManager.shared()?.isFeedbackEnabled = true
//        #else
//        PgyManager.shared()?.isFeedbackEnabled = false
//        #endif
//        PgyManager.shared()?.feedbackActiveType = .pgyFeedbackActiveTypeShake
//        PgyManager.shared()?.themeColor = UIColor.primary()
//        PgyManager.shared()?.shakingThreshold = 2.5

    }

    func setupOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any])  {
        #if DEBUG
        OneSignal.setLogLevel(.LL_DEBUG, visualLevel: .LL_NONE)
        #endif
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                     kOSSettingsKeyInAppLaunchURL: false]

        let handleNotificationAction: OSHandleNotificationActionBlock = { element  in
            guard let element: OSNotificationOpenedResult = element else { return }
            NotificationCenter.default.post(name: .kNotificationReceived, object: nil,
                                            userInfo: element.notification.payload.additionalData)

        }

        let handleNotificationReceived: OSHandleNotificationReceivedBlock = { element  in
            guard let element: OSNotification = element else { return }
            print(String(repeating: "-", count: 50))
            print("rawPayload: \(element.payload.rawPayload?.description ?? "")")
            print("additionalData: \(element.payload.additionalData?.description ?? "")")
        }

        let messageClickHandler: OSHandleInAppMessageActionClickBlock = { action  in
            guard let action = action else { return }
            print(String(repeating: "-", count: 50))
            print("clickName: \(action.clickName ?? "")")
            print("clickUrl: \(action.clickUrl?.absoluteString ?? "")")
            print("closesMessage: \(action.closesMessage)")
        }

        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Keys.Onesignal.appId,
                                        handleNotificationReceived: handleNotificationReceived,
                                        handleNotificationAction: handleNotificationAction,
                                        settings: onesignalInitSettings)

        OneSignal.setInAppMessageClickHandler(messageClickHandler)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification

        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.add(self as OSPermissionObserver)

    }

    func setupCocoaDebug() {
        #if DEBUG
        CocoaDebug.serverURL = Configs.Network.url
        CocoaDebug.ignoredURLs = []
        CocoaDebug.onlyURLs = []
        CocoaDebug.logMaxCount = 1000
        CocoaDebug.emailToRecipients = ["coderhaiyang@gmail.com"]
        CocoaDebug.mainColor = "#fd9727"
        #endif
    }

}

extension LibsManager {

    func showFlex() {
        #if DEBUG
        FLEXManager.shared.showExplorer()
        #endif
    }

    func removeKingfisherCache() -> Observable<Void> {
        return ImageCache.default.rx.clearCache()
    }

    func kingfisherCacheSize() -> Observable<Int> {
        return ImageCache.default.rx.retrieveCacheSize()
    }

}

//extension LibsManager : OpenInstallDelegate {
//
//    //通过OpenInstall获取已经安装App被唤醒时的参数（如果是通过渠道页面唤醒App时，会返回渠道编号）
//    func getWakeUpParams(_ appData: OpeninstallData?) {
//        if appData?.data != nil {
//            //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
//        }
//        if appData?.channelCode != nil{
//            //e.g.可自己统计渠道相关数据等
//        }
//        print("唤醒参数 data = \(String(describing: appData?.data)),channelCode = \(String(describing: appData?.channelCode))")
//    }
//}

extension LibsManager: OSSubscriptionObserver, OSPermissionObserver {

    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {

        // The user is subscribed
        // Either the user subscribed for the first time
        // Or the user was subscribed -> unsubscribed -> subscribed
        print(stateChanges.to.userId)
        print(stateChanges.toDictionary())
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {

           print(stateChanges.to.userId)
        }

    }

    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
       // Example of detecting answering the permission prompt
       if stateChanges.from.status == OSNotificationPermission.notDetermined {
          if stateChanges.to.status == OSNotificationPermission.authorized {
             logDebug("Thanks for accepting notifications!")
          } else if stateChanges.to.status == OSNotificationPermission.denied {
             logDebug("Notifications not accepted. You can turn them on later under your iOS settings.")
          }
       }
       // prints out all properties
        logDebug("PermissionStateChanges: \n\(String(describing: stateChanges))")
    }

}
