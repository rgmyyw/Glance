//
//  AppearanceManager.swift
//  
//
//  Created by yanghai on 2019/12/24.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class AppearanceManager {

    static let shared = AppearanceManager()
    private init() {}

    func setup() {

        let textField = UITextField.appearance()
        textField.clearButtonMode = .whileEditing
        themeService.rx.bind({$0.primary }, to: textField.rx.tintColor)

        let textView = UITextView.appearance()
        themeService.rx.bind({$0.primary }, to: textView.rx.tintColor)

        let tabbar = UITabBar.appearance()
        tabbar.backgroundImage = UIImage()
        tabbar.shadowImage = UIImage()

        let tableView = UITableView.appearance()
        tableView.separatorStyle = .none

        let navigationBar = UINavigationBar.appearance()
        navigationBar.tintColor = UIColor.white
        navigationBar.barTintColor = navigationBar.tintColor

    }
}
