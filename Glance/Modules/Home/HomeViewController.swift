//
//  HomeViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class HomeViewController: CollectionViewController {
    
    lazy var customNavigationBar : HomeNavigationBar = HomeNavigationBar.loadFromNib(height: 44,width: self.view.width) 
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.addSubview(customNavigationBar)
    }
}
