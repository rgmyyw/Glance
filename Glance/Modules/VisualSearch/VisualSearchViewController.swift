//
//  VisualSearchViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/28.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchViewController: ViewController {
    
    let cropView : VisualSearchCropView = VisualSearchCropView()
    
    override func makeUI() {
        super.makeUI()
        
        contentView.removeFromSuperview()
        view.addSubview(cropView)
        cropView.frame = view.bounds
        cropView.image = UIImage(named: "20.png")
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
    }
    

}
