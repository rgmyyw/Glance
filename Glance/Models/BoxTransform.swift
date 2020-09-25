//
//  [Int]RectArra.swift
//  Glance
//
//  Created by yanghai on 2020/8/17.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper




class BoxTransform: TransformType {
    
    func transformFromJSON(_ value: Any?) -> Box? {
        if let i = value as? [Int] , i.count == 4 {
            return Box(json: i)
        }
        return nil

    }
    
    func transformToJSON(_ value: Box?) -> [Int]? {
        if let i = value {
            return i.toIntArray()
        }
        return nil

    }
    
    
    typealias Object = Box
    typealias JSON = [Int]

    

    public init() {}
}

