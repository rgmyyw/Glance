//
//  Box.swift
//  Glance
//
//  Created by yanghai on 2020/8/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct Box : Equatable, CustomStringConvertible {
    
    var description: String {
        return "px: \(string)"
    }
    
    // 是否为默认点,默认点不可删除.
    var `default` : Bool
    
    var x1 : Int = 0
    var y1 : Int = 0
    var x2 : Int = 0
    var y2 : Int = 0
    
    var string : String {
        return "x1:\(x1),y1:\(y1),x2:\(x2),y2:\(y2)"
    }
    
    
    /// JSON 初始化:
    /// - Parameter json: json list
    init(json : [Int], isDefault : Bool = false) {
        if json.count != 4 { fatalError()}
        
        x1 = json[0]
        y1 = json[1]
        x2 = json[2]
        y2 = json[3]
        self.default = isDefault
    }
    
    static var zero : Box {
        return Box(json: [0,0,0,0])
    }
    
    var intArray: [Int] {
        return [x1,y1,x2,y2]
    }
    
    /// 转换成Pt
    /// - Parameters:
    ///   - originSize: 原始大小
    ///   - referenceSize: 参照物
    func transformCGRect(from size : CGSize) -> CGRect {
        let x = x1.cgFloat / (size.width / UIScreen.width)
        let y = y1.cgFloat / (size.width / UIScreen.width)
        let w = (x2.cgFloat - x1.cgFloat) / (size.width / UIScreen.width)
        let h = (y2.cgFloat - y1.cgFloat) / (size.width / UIScreen.width)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        let offset : Int = 5
        switch lhs.x1 - rhs.x1 {
        case (-offset)...offset:
            break
        default:
            return false
        }
        
        switch lhs.x2 - rhs.x2 {
        case (-offset)...offset:
            break
        default:
            return false
        }

        switch lhs.y1 - rhs.y1 {
        case (-offset)...offset:
            break
        default:
            return false
        }

        switch lhs.y2 - rhs.y2 {
        case (-offset)...offset:
            break
        default:
            return false
        }

        return true
    }
    
}
