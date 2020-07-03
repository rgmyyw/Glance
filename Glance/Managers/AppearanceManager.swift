//
//  AppearanceManager.swift
//  
//
//  Created by yanghai on 2019/12/24.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit

class AppearanceManager {
    
    static let shared = AppearanceManager()
    private init() {}
        
    func setup() {
        
        UITextField.appearance().clearButtonMode = .whileEditing
        themeService.rx.bind( {$0.primary }, to: UITextField.appearance().rx.tintColor)
        
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        
        UITableView.appearance().separatorStyle = .none
        
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        
        
        
        UINavigationBar.appearance()
        
        //            themeService.rx
        //                .bind({ $0.global }, to: navigationBar.rx.tintColor)
        //                .bind({ $0.global }, to: navigationBar.rx.barTintColor)
        //                .bind({ [NSAttributedString.Key.foregroundColor: $0.text, NSAttributedString.Key.font : UIFont.titleFont(18)] }, to: navigationBar.rx.titleTextAttributes)
        //                .disposed(by: rx.disposeBag)

    }
    
    
}
