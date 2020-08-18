//
//  [Int]RectArra.swift
//  Glance
//
//  Created by yanghai on 2020/8/17.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

open class IntPxArrayToPtRectTransform: TransformType {
    
    public func transformFromJSON(_ value: Any?) -> CGRect? {
        if let i = value as? [Int] , i.count == 4 {
            return CGRect(x: i[0].cgFloat, y: i[1].cgFloat, w: i[3].cgFloat, h: i[4].cgFloat)
        }
        return nil

    }
    
    public func transformToJSON(_ value: CGRect?) -> [Int]? {
        if let i = value {
            return [i.x.int,i.y.int,i.width.int,i.height.int]
        }
        return nil

    }
    

    public typealias Object = CGRect
    public typealias JSON = [Int]

    public init() {}

}

