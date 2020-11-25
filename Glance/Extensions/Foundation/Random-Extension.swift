//
//  Random-Extension.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

extension String {

    static func random() -> String {
        return self.random(ofLength: Int.random(in: 10...30))
    }

}
