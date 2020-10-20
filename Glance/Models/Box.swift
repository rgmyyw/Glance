//
//  Box.swift
//  Glance
//
//  Created by yanghai on 2020/8/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
import RxCocoa

class VisualSearchDot {
    
    enum State {
        case normal
        case selected
        case hidden
    }
    
    let box : Box

    let state = BehaviorRelay<State>(value: .hidden)
    
    var selected : DefaultColltionItem? {
        didSet { updateState() }
    }
    var current : Box? {
        didSet { updateState() }
    }
    
    let image : UIImage
    
    init(box : Box, image : UIImage) {
        
        // 检查是否超出限定边界,过滤掉，超出边界的区域
        let inset = 20
        var element = box
        if element.x1 < inset {
            element.x1 = inset
        }
        if element.y1 < UIApplication.shared.statusBarFrame.height.int {
            element.y1 = UIApplication.shared.statusBarFrame.height.int
        }
        if element.x1 + element.x2 > image.size.width.int {
            element.x2 = image.size.width.int - inset
        }
        
        if element.y1 + element.y2 > image.size.height.int {
            element.y2 = image.size.height.int - inset
        }
        self.box = element
        self.image = image
    }
    
    func updateState() {
        if current == box {
            state.accept(.hidden)
            return
        }
        if box.default {
            state.accept(selected == nil ? .normal : .selected)
        } else {
            state.accept(selected == nil ? .hidden : .selected)
        }
    }
}


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
        return "x1:\(x1),y1:\(x2),x2:\(y1),y2:\(y2)"
    }
    
    /// cgrect初始化:
    /// - Parameter rect: PT rect
    init(rect : CGRect) {
        x1 = rect.origin.x.int
        y1 = rect.origin.y.int
        x2 = rect.size.width.int + x1
        y2 = rect.size.height.int + y1
        self.default = false
    }
    
    
    /// JSON 初始化:
    /// - Parameter json: json list
    init(json : [Int]) {
        if json.count != 4 { fatalError()}
        
        x1 = json[0]
        y1 = json[1]
        x2 = json[2]
        y2 = json[3]
        self.default = true
    }
    
    static var zero : Box {
        return Box(rect: .zero)
    }
    
    var intArray: [Int] {
        return [x1,y1,x2,y2]
    }
    
    var cgRect : CGRect {
        return CGRect(x: x1.cgFloat, y: y1.cgFloat,
                      width: CGFloat(x2 - x1), height: CGFloat(y2 - y1))
    }
    
    
    /// 转换成Px
    /// - Parameters:
    ///   - originSize: 原始大小
    ///   - referenceSize: 参照物
    func transformPx(originSize : CGSize, referenceSize : CGSize) -> Box {
        let rect = cgRect
        let x = originSize.width.int / referenceSize.width.int * rect.origin.x.int
        let y = originSize.height.int / referenceSize.height.int * rect.origin.y.int
        let w = originSize.width.int / referenceSize.width.int * rect.width.int
        let h = originSize.height.int / referenceSize.height.int * rect.height.int
        return Box(rect: CGRect(x: x.cgFloat, y: y.cgFloat, width: w.cgFloat, height: h.cgFloat))
    }
    
    /// 转换成Pt
    /// - Parameters:
    ///   - originSize: 原始大小
    ///   - referenceSize: 参照物
    func transformPt(originSize : CGSize, referenceSize : CGSize) -> CGRect {
        let rect = cgRect
        let x =  rect.origin.x.int * referenceSize.width.int / originSize.width.int
        let y = rect.origin.y.int * referenceSize.height.int / originSize.height.int
        let w = rect.width.int * referenceSize.width.int / originSize.width.int
        let h = rect.height.int * referenceSize.height.int / originSize.height.int
        return CGRect(x: x.cgFloat, y: y.cgFloat, width: w.cgFloat, height: h.cgFloat)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        let offset : Int = 10
        let lhsRect = lhs.cgRect
        let rhsRect = rhs.cgRect
        switch lhsRect.center.x.int - rhsRect.center.x.int {
        case (-offset)...offset:
            break
        default:
            return false
        }
        
        switch lhsRect.center.y.int - rhsRect.center.y.int {
        case (-offset)...offset:
            break
        default:
            return false
        }

        return true
    }
    
}
