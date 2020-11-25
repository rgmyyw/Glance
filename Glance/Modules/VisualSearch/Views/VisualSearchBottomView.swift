//
//  VisualSearchBottomView.swift
//  Glance
//
//  Created by yanghai on 2020/7/31.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchBottomView: View {

    @IBOutlet weak var button: UIButton!

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let point = convert(point, to: button)
        if button.point(inside: point, with: event), button.isUserInteractionEnabled, button.isEnabled, button.alpha > 0 {
            return button
        } else {
            return nil
        }
    }
}
