//
//  DefaultColltionMemu.swift
//  Glance
//
//  Created by yanghai on 2020/10/23.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit


enum DefaultColltionMemu : Int  {
    case like = 0
    case share = 1
    case delete = 2
    case report = 3
    
    static var own : [DefaultColltionMemu] = [.like,.share,.delete]
    static var other : [DefaultColltionMemu] = [.like,.share,.report]
}
