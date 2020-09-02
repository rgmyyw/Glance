//
//  UserHeadView.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class UserHeadView: View {

    @IBOutlet weak var userHeadImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
        
    @IBOutlet weak var instagramCell: UIView!
    @IBOutlet weak var websiteCell: UIView!
    @IBOutlet weak var bioCell: UIView!
    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var ownUserBgView: UIView!
    @IBOutlet weak var otherUserBgView: UIView!
    @IBOutlet weak var otherUserDisplayNameLabel: UILabel!
    @IBOutlet weak var otherUserCountryButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    
    override func makeUI() {
        super.makeUI()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
