//
//  OriginalPhotosViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class OriginalPhotosViewController: ViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    override func makeUI() {
        super.makeUI()
        navigationTitle = "Original photos"
        stackView.addArrangedSubview(scrollView)
    }

}
