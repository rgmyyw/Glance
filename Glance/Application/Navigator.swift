//
//  Navigator.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SafariServices
import AcknowList
import MessageUI
import Hero
import PopupDialog

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    static var `default` = Navigator()
    
    // MARK: - segues list, all app scenes
    enum Scene {
        case demo(viewModel : DemoViewModel)
        case safari(URL)
        case safariController(URL)
        case webController(URL)
        case tabs(viewModel: HomeTabBarViewModel)
        case signIn
        case modifyProfile(viewModel : ModifyProfileViewModel)
        case notificationProfile(viewModel : NotificationProfileViewModel)
    }
    
    enum Transition {
        case root(in: UIWindow)
        case demo(in: UIWindow)
        case navigation(type: HeroDefaultAnimationType)
        case customModal(type: HeroDefaultAnimationType)
        case modal
        case detail
        case alert
        case custom
        case popDialog
    }
    
    // MARK: - get a single VC
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .safari(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil
        case .safariController(let url):
            let vc = SFSafariViewController(url: url)
            return vc
        case .webController(let url):
            let vc = WebViewController(viewModel: nil, navigator: self)
            vc.load(url: url)
            return vc
        case .tabs(let viewModel):
            let rootVC = HomeTabBarController(viewModel: viewModel, navigator: self)
            return rootVC
        case .demo(let viewModel):
            let vc = DemoViewController(viewModel: viewModel, navigator: self)
            return NavigationController(rootViewController: vc)
        case .signIn:
            let vc = SignInViewController()
            return vc
        case .modifyProfile(let viewModel):
            let vc = ModifyProfileViewController(viewModel: viewModel, navigator: self)
            return vc
        case .notificationProfile(let viewModel):
            let vc = NotificationProfileViewController(viewModel: viewModel, navigator: self)
            return vc
        }
    }
    
    
    /// - Parameter number: 返回几个页面
    func pop(sender: UIViewController?, toRoot: Bool = false , page  : Int = 0) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else if page > 0 && page < (sender?.navigationController?.viewControllers.count ?? 0) - 1{
            let controllers = sender?.navigationController?.viewControllers
            if let count = controllers?.count, let controller =  controllers?[(count - 1) - page] {
                sender?.navigationController?.popToViewController(controller, animated: true)
            } else {
                sender?.navigationController?.popViewController()
            }
        } else {
            sender?.navigationController?.popViewController()
        }
    }
    
    
    
    func dismiss(sender: UIViewController?, animated : Bool = true ) {
        
        if let sender = sender, sender.isKind(of: NavigationController.self) {
            sender.dismiss(animated: animated, completion: nil)
        } else  {
            sender?.navigationController?.dismiss(animated: animated, completion: nil)
        }
    }
    
    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, animated : Bool = true, transition: Transition = .navigation(type: .cover(direction: .left))) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, animated : animated, transition: transition)
        }
    }
    
    private func show(target: UIViewController, sender: UIViewController?,animated : Bool = true, transition: Transition) {
        switch transition {
        case .root(in: let window),.demo(in: let window):
            window.rootViewController = target
            return
        case .custom: return
        default: break
        }
        
        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }
        
        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }
        
        switch transition {
        case .navigation(let type):
            if let nav = sender.navigationController {
                // push controller to navigation stack
                nav.hero.navigationAnimationType = .autoReverse(presenting: type)
                nav.pushViewController(target, animated: animated)
            }
        case .customModal(let type):
            // present modally with custom animation
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                nav.hero.modalAnimationType = .autoReverse(presenting: type)
                sender.present(nav, animated: animated, completion: nil)
            }
        case .modal:
            // present modally
            let nav = NavigationController(rootViewController: target)
            nav.modalPresentationStyle = .custom
            sender.present(nav, animated: animated, completion: nil)
            
        case .detail:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                sender.present(target, animated: animated, completion: nil)
            }
        case .popDialog:
            DispatchQueue.main.async {
                let popup = PopupDialog(viewController: target, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: true, panGestureDismissal: false)
                sender.present(popup, animated: animated, completion: nil)
            }
        default: break
        }
    }
    
    func toInviteContact(withPhone phone: String) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.body = "Hey! Come join  at \(Configs.App.url)"
        vc.recipients = [phone]
        return vc
    }
    
    
}
