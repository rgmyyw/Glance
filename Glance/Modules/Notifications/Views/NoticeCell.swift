//
//  NoticeCell.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class NoticeCell: TableViewCell {

    @IBOutlet weak var bgView: UIView!
    
    override func makeUI() {
        super.makeUI()
         
        let shadowOffset = CGSize(width: 0, height: 1)
        let color = UIColor(hex:0x828282)!.withAlphaComponent(0.2)
        let opacity : CGFloat = 1
        bgView.shadow(cornerRadius: 8, shadowOpacity: opacity, shadowColor: color, shadowOffset: shadowOffset, shadowRadius: 5)

    }
}
