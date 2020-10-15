//
//  Box.swift
//  Glance
//
//  Created by yanghai on 2020/8/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct Box : Equatable {
    
    var x1 : Int = 0
    var y1 : Int = 0
    var x2 : Int = 0
    var y2 : Int = 0
    
    var string : String {
        return "\(x1),\(x2),\(y1),\(y2)"
    }
    
    
    /// PT 初始化
    /// - Parameter rect: PT rect
    init(rect : CGRect) {
        x1 = rect.origin.x.int
        y1 = rect.origin.y.int
        x2 = rect.size.width.int + x1
        y2 = rect.size.height.int + y1
    }
    
    
    /// JSON 初始化
    /// - Parameter json: json list
    init(json : [Int]) {
        if json.count != 4 { fatalError()}
        x1 = json[0]
        y1 = json[1]
        x2 = json[2]
        y2 = json[3]
    }
    
    
    static var zero : Box {
        return Box(rect: .zero)
    }
    
    
    
    func toIntArray () -> [Int]{
        return [x1,y1,x2,y2]
    }
    
    func toCGRect()  -> CGRect {
        return CGRect(x: x1.cgFloat, y: y1.cgFloat, width: CGFloat(x2 - x1), height: CGFloat(y2 - y1))
    }
    
    func transformPx(originSize : CGSize, referenceSize : CGSize) -> Box {
        let rect = toCGRect()
        let x = originSize.width / referenceSize.width * rect.origin.x
        let y = originSize.height / referenceSize.height * rect.origin.y
        let w = originSize.width / referenceSize.width * rect.width
        let h = originSize.height / referenceSize.height * rect.height
        
        return Box(rect: CGRect(x: x, y: y, width: w, height: h))
    }
    
    func transformPt(originSize : CGSize, referenceSize : CGSize) -> CGRect {
        
        let rect = toCGRect()
        let x =  rect.origin.x * referenceSize.width / originSize.width
        let y = rect.origin.y * referenceSize.height / originSize.height
        let w = rect.width * referenceSize.width / originSize.width
        let h = rect.height * referenceSize.height / originSize.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        let offset : CGFloat = 10
        //        switch lhs.x1 - rhs.x1 {
        //        case (-offset)...offset:
        //            break
        //        default:
        //            return false
        //        }
        //        switch lhs.x2 - rhs.x2 {
        //        case (-offset)...offset:
        //            break
        //        default:
        //            return false
        //        }
        //        switch lhs.y1 - rhs.y1 {
        //        case (-offset)...offset:
        //            break
        //        default:
        //            return false
        //        }
        //        switch lhs.y2 - rhs.y2 {
        //        case (-offset)...offset:
        //            break
        //        default:
        //            return false
        //        }
        
        
        let lhsRect = lhs.toCGRect()
        let rhsRect = rhs.toCGRect()
        switch lhsRect.center.x - rhsRect.center.x {
        case (-offset)...offset:
            break
        default:
            return false
        }
        
        switch lhsRect.center.y - rhsRect.center.y {
        case (-offset)...offset:
            break
        default:
            return false
        }

        return true
    }
    
}
