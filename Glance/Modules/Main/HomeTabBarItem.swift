//
//  HomeTabBarItem.swift
//  Glance
//
//  Created by yanghai on 2020/11/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController

enum HomeTabBarItem: Int {

    case home, notifications, chat, mine, center
    private func controller(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        switch self {
        case .home:
            let vc = HomeController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        case .notifications:
            let vc = NoticeViewController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        case .chat:
            let vc = NoticeViewController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        case .mine:
            let vc = UserDetailViewController(viewModel: viewModel, navigator: navigator)
            return NavigationController(rootViewController: vc)
        case .center:
            return DemoViewController.init(viewModel: viewModel, navigator: navigator)
        }
    }

    var imageNormal: UIImage? {
        switch self {
        case .home:
            return R.image.icon_tabbar_home_normal()?.withRenderingMode(.alwaysOriginal)
        case .notifications: return R.image.icon_tabbar_notice_normal()?.withRenderingMode(.alwaysOriginal)
        case .chat: return R.image.icon_tabbar_message_normal()?.withRenderingMode(.alwaysOriginal)
        case .mine: return R.image.icon_tabbar_mine_normal()?.withRenderingMode(.alwaysOriginal)
        case .center: return R.image.icon_tabbar_add()?.withRenderingMode(.alwaysOriginal)
        }
    }

    var imageSelected: UIImage? {
        switch self {
        case .home: return R.image.icon_tabbar_home_selected()?.withRenderingMode(.alwaysOriginal)
        case .notifications: return R.image.icon_tabbar_notice_selected()?.withRenderingMode(.alwaysOriginal)
        case .chat: return R.image.icon_tabbar_message_selected()?.withRenderingMode(.alwaysOriginal)
        case .mine: return R.image.icon_tabbar_mine_selected()?.withRenderingMode(.alwaysOriginal)
        case .center: return R.image.icon_tabbar_add()?.withRenderingMode(.alwaysOriginal)
        }
    }

    var title: String {
        switch self {
        default:
            return ""
        }
    }

    var animation: RAMItemAnimation {
        var animation: RAMItemAnimation
        switch self {
        default:
            let item = CustomBounceAnimation()
            item.normalImage = imageNormal
            item.selectedImage = imageSelected
            item.textSelectedColor = UIColor.primary()
            animation = item
        }

        return animation
    }

    func getController(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        let vc = controller(with: viewModel, navigator: navigator)
        let item = CustomAnimatedTabBarItem(title: title, image: imageNormal, tag: rawValue)
        item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: UIApplication.shared.statusBarFrame.height == 20 ? 6 :  12)
        item.selectedImage = imageSelected
        item.animation = animation
        item.textColor = UIColor.text()
        vc.tabBarItem = item
        return vc
    }

}
