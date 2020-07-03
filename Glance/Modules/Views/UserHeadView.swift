//
//  UserHeadView.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

@IBDesignable
class UserHeadView: View  {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBInspectable var image : UIImage? {
        didSet {
            imageView.image = image
            setNeedsDisplay()
        }
    }
        
    override func makeUI() {
        super.makeUI()
    }
    
}
