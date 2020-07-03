//
//  DemoViewController.swift
//  Popupable_Example
//
//  Created by 杨海 on 2020/5/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class DemoViewController: ViewController {    
    
    @IBOutlet weak var containerView: UIView!
    @IBAction func click() {
        
    }
       
    override func makeUI() {
        super.makeUI()
        
        navigationBar.title = "1123asdsa"
        stackView.addArrangedSubview(containerView)
    }


}
