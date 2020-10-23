//
//  VisualSearchDotCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/10/23.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VisualSearchDotCellViewModel {
    
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
        let inset = (10 * (image.size.width / UIScreen.width)).int
        let topInset = (UIApplication.shared.statusBarFrame.height * (image.size.width / UIScreen.width)).int
        var element = box
        if element.x1 < inset {
            element.x1 = inset
        }
        if element.y1 < topInset {
            element.y1 = topInset
        }
        
        if element.x2 > (image.size.width.int  - inset){
            element.x2 = image.size.width.int - inset
        }

        if element.y2 > (image.size.height.int - inset){
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



extension CGRect {
    
    func transformPixel(from size : CGSize) -> Box {
        
        let x1 = origin.x * (size.width / UIScreen.width)
        let y1 = origin.y * (size.width / UIScreen.width)
        let x2 = (origin.x + self.size.width) * (size.width / UIScreen.width)
        let y2 = (origin.y + self.size.height) * (size.width / UIScreen.width)
        return Box(json: [x1.int,y1.int,x2.int,y2.int])
    }
}
