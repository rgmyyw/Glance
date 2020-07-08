//
//  NotificationProfileViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class NotificationProfileViewController: ViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func makeUI() {
        super.makeUI()
        navigationTitle = "Notifications"
        stackView.addArrangedSubview(scrollView)
    }

}
