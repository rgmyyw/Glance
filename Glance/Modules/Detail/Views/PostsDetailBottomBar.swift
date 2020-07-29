//
//  PostsDetailBottomBar.swift
//  Glance
//
//  Created by yanghai on 2020/7/27.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PostsDetailBottomBar: View {
    
    
    @IBOutlet weak var addButton: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func makeUI() {
        
        super.makeUI()
        isHidden = true
    }

}
