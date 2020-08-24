//
//  ComparePriceCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import SwipeCellKit

class ComparePriceCell: SwipeTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = nil
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { (view) in
            
            if view.className == "SwipeActionsView" {
                view.addGradient(colors: [UIColor(hex: 0xFBE8E2),UIColor(hex: 0xFFB39F),UIColor(hex: 0xFF8159)])
            }
        }
    }

    
    
}

extension UIView {
    

    
    func logViewHierarchy() {
        print(self.className)
        subviews.forEach { (view) in
            view.logViewHierarchy()
        }
    }
}

