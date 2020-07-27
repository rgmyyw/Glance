//
//  PostsDetailNavigationBar.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostsDetailNavigationBar: View {
    
    
    @IBOutlet weak var ownImageView: UIImageView!
    @IBOutlet weak var otherImageView: UIImageView!
    @IBOutlet weak var ownNameLabel: UILabel!
    @IBOutlet weak var otherNameLabel: UILabel!
    @IBOutlet weak var ownTimeLabel: UILabel!
    @IBOutlet weak var otherTimeLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var otherBgView: UIView!
    @IBOutlet weak var ownBgView: UIView!
    
    @IBOutlet weak var ownImageWidth: NSLayoutConstraint!
    
    
}
