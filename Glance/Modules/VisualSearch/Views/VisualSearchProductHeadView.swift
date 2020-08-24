//
//  VisualSearchProductHeadView.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchProductHeadView: View {
    
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func makeUI() {
        super.makeUI()
        
        textFiled.addPaddingLeft(12)
    }
}
