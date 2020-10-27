//
//  Navigator.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
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
import FloatingPanel

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
        case signIn(viewModel: SignInViewModel)
        case modifyProfile(viewModel : ModifyProfileViewModel)
        case notificationProfile(viewModel : NotificationProfileViewModel)
        case originalPhotos(viewModel : OriginalPhotosViewModel)
        case privacy(viewModel : PrivacyViewModel)
        case users(viewModel : UsersViewModel)
        case insights(viewModel : InsightsViewModel)
        case insightsDetail(viewModel : InsightsDetailViewModel)
        case reactions(viewModel : ReactionsViewModel)
        case dynamicDetail(viewModel : PostsDetailViewModel)
        case shoppingCart(viewModel : ShoppingCartViewModel)
        case savedCollectionClassify(viewModel : SavedCollectionClassifyViewModel)
        case savedCollection(viewModel : SavedCollectionViewModel)
        case interest(viewModel : InterestViewModel)
        case visualSearch(viewModel: VisualSearchViewModel)
        case visualSearchProduct(viewModel: VisualSearchProductViewModel)
        case addProduct(viewModel: AddProductViewModel)
        case postProduct(viewModel: PostProductViewModel)
        case styleBoard(viewModel: StyleBoardViewModel)
        case styleBoardSearch(viewModel: StyleBoardSearchViewModel)
        case styleBoardSearchContent(viewModel: StyleBoardSearchContentViewModel)
        case insightsRelation(viewModel : InsightsRelationViewModel)
        case userDetail(viewModel : UserDetailViewModel)
        case userPost(viewModel : UserDetailPostViewModel)
        case userRecommend(viewModel : UserDetailRecommViewModel)
        case searchRecommend(viewModel : SearchRecommendViewModel)
        case searchRecommendHot(viewModel : SearchRecommendHotViewModel)
        case searchRecommendYouMayLike(viewModel : SearchRecommendYouMayLikeViewModel)
        case searchRecommendNew(viewModel : SearchRecommendNewViewModel)
        case search(viewModel : SearchViewModel)
        case searchResult(viewModel : SearchResultViewModel)
        case searchResultContent(viewModel : SearchResultContentViewModel)
        case searchTheme(viewModel : SearchThemeViewModel)
        case searchThemeContent(viewModel : SearchThemeContentViewModel)
        case searchThemeLabel(viewModel : SearchThemeLabelViewModel)
        case searchThemeLabelContent(viewModel : SearchThemeLabelContentViewModel)
        case selectStore(viewModel : SelectStoreViewModel)

    }
    
    enum Transition {
        case root(in: UIWindow)
        case navigation(type: HeroDefaultAnimationType)
        case customModal(type: HeroDefaultAnimationType)
        case modal
        case detail
        case alert
        case custom
        case popDialog
        case panel(style : PanelDefaultModalStyle)
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
        case .signIn(let viewModel):
            let vc = SignInViewController(viewModel: viewModel, navigator: self)
            return vc
        case .modifyProfile(let viewModel):
            let vc = ModifyProfileViewController(viewModel: viewModel, navigator: self)
            return vc
        case .notificationProfile(let viewModel):
            let vc = NotificationProfileViewController(viewModel: viewModel, navigator: self)
            return vc
        case .originalPhotos(let viewModel):
            let vc = OriginalPhotosViewController(viewModel: viewModel, navigator: self)
            return vc
        case .privacy(let viewModel):
            let vc = PrivacyViewController(viewModel: viewModel, navigator: self)
            return vc
        case .users(let viewModel):
            let vc = UsersViewController(viewModel: viewModel, navigator: self,tableView: .grouped)
            return vc
        case .insights(let viewModel):
            let vc = InsightsViewController(viewModel: viewModel, navigator: self)
            return vc
        case .insightsDetail(let viewModel):
            let vc = InsightsDetailViewController(viewModel: viewModel, navigator: self)
            return vc
        case .reactions(let viewModel):
            let vc = ReactionsViewController(viewModel: viewModel, navigator: self)
            return vc
        case .dynamicDetail(let viewModel):
            let vc = PostsDetailViewController(viewModel: viewModel, navigator: self)
            return vc
        case .shoppingCart(let viewModel):
            let vc = ShoppingCartViewController(viewModel: viewModel, navigator: self)
            return vc
        case .savedCollectionClassify(let viewModel):
            let vc = SavedCollectionClassifyViewController(viewModel: viewModel, navigator: self)
            return vc
        case .savedCollection(let viewModel):
            let vc = SavedCollectionViewController(viewModel: viewModel, navigator: self)
            return vc
        case .interest(let viewModel):
            let vc = InterestViewController(viewModel: viewModel, navigator: self)
            return vc
        case .visualSearch(let viewModel):
            let vc = VisualSearchViewController(viewModel: viewModel, navigator: self)
            return vc
        case .visualSearchProduct(let viewModel):
            let vc = VisualSearchProductViewController(viewModel: viewModel, navigator: self)
            return vc
        case .addProduct(let viewModel):
            let vc = AddProductViewController(viewModel: viewModel, navigator: self)
            return vc
        case .postProduct(let viewModel):
            let vc = PostProductViewController(viewModel: viewModel, navigator: self)
            return vc
            
        case .styleBoard(let viewModel):
            let vc = StyleBoardViewController(viewModel: viewModel, navigator: self)
            return vc
        case .styleBoardSearch(let viewModel):
            let vc = StyleBoardSearchViewController(viewModel: viewModel, navigator: self)
            return vc
        case .styleBoardSearchContent(let viewModel):
            let vc = StyleBoardSearchContentViewController(viewModel: viewModel, navigator: self)
            return vc
        case .insightsRelation(let viewModel):
            let vc = InsightsRelationViewController(viewModel: viewModel, navigator: self)
            return vc
        case .userDetail(let viewModel):
            let vc = UserDetailViewController(viewModel: viewModel, navigator: self)
            return vc
        case .userPost(let viewModel):
            let vc = UserDetailPostViewController(viewModel: viewModel, navigator: self)
            return vc
        case .userRecommend(let viewModel):
            let vc = UserDetailRecommViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchRecommend(let viewModel):
            let vc = SearchRecommendViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchRecommendHot(let viewModel):
            let vc = SearchRecommendHotViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchRecommendYouMayLike(let viewModel):
            let vc = SearchRecommendYouMayLikeViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchRecommendNew(let viewModel):
            let vc = SearchRecommendNewViewController(viewModel: viewModel, navigator: self)
            return vc
        case .search(let viewModel):
            let vc = SearchViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchResultContent(let viewModel):
            let vc = SearchResultContentViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchResult(let viewModel):
            let vc = SearchResultViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchTheme(let viewModel):
            let vc = SearchThemeViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchThemeContent(let viewModel):
            let vc = SearchThemeContentViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchThemeLabel(let viewModel):
            let vc = SearchThemeLabelViewController(viewModel: viewModel, navigator: self)
            return vc
        case .searchThemeLabelContent(let viewModel):
            let vc = SearchThemeLabelContentViewController(viewModel: viewModel, navigator: self)
            return vc
        case .selectStore(let viewModel):
            let vc = SelectStoreViewController(viewModel: viewModel, navigator: self)
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
    
    
    
    func dismiss(sender: UIViewController?, animated : Bool = true , completion : (()->())? = nil) {
        
        if let sender = sender, sender.isKind(of: NavigationController.self) {
            sender.dismiss(animated: animated, completion: completion)
        } else if let navigationController = sender?.navigationController  {
            navigationController.dismiss(animated: animated, completion: completion)
        } else {
            sender?.dismiss(animated: animated, completion: completion)

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
        case .root(in: let window):
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
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                nav.modalPresentationStyle = .custom
                sender.present(nav, animated: animated, completion: nil)
            }
            
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
        case .panel(let style):
            
            var delegate : (UIViewController & FloatingPanelControllerDelegate)!
            if target.isKind(of: UINavigationController.self) {
                delegate = (target as! UINavigationController).viewControllers.first as? (UIViewController & FloatingPanelControllerDelegate)
            } else if target.isKind(of: UIViewController.self) {
                delegate = target as? (UIViewController & FloatingPanelControllerDelegate)
            } else if target.isKind(of: UITabBarController.self) {
                fatalError("Does not support")
            }
            guard delegate != nil else {
                fatalError("target not conforms FloatingPanelControllerDelegate")
            }
            let fpc = FloatingPanelController()
            fpc.set(contentViewController: target)
            fpc.surfaceView.setValue(style.cornerRadius, forKey: "cornerRadius")
            fpc.surfaceView.setValue(style.borderWidth, forKey: "borderWidth")
            fpc.surfaceView.setValue(style.borderColor, forKey: "borderColor")
            fpc.surfaceView.shadowHidden = style.shadowHidden
            fpc.isRemovalInteractionEnabled = style.isRemovalInteractionEnabled
            fpc.delegate = delegate
            sender.present(fpc, animated: animated, completion: nil)
            
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


