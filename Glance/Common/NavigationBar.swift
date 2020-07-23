//
//  NavigationBar.swift
//  
//
//  Created by 杨海 on 2020/5/11.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import SnapKit

class NavigationBar: View {
    
    private lazy var leftView : UIView = UIView()
    private lazy var rightView : UIView = UIView()
    
    private lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.titleBoldFont(18)
        titleLabel.textColor = UIColor.text()
        return titleLabel
    }()
    
    
    
    
    
    public var title : String? {
        didSet {
            
            titleLabel.text = title
            
            /// 方案一: title 左对齐
            /// /**
            if titleLabel.superview == nil {
                leftBarButtonItems.append(titleLabel)
                layoutSubviews()
            }
            /// 方案二: title 居中对齐
            /**
            titleLabel.sizeToFit()
            layoutSubviews()
            */
        }
    }
    
    
    
    public var leftBarButtonItems : [UIView] = []
    public var rightBarButtonItems : [UIView] = []
    public var contentInset : UIEdgeInsets = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
    public var itemMargin : CGFloat = 20
    
    
    public var backBarButtonItem : UIButton? {
        didSet {
            guard let view = backBarButtonItem else {
                return
            }
            leftBarButtonItems.insert(view, at: 0)
        }
    }
    
    public var leftBarButtonItem : UIView?  {
        set {
            guard let view = newValue else { return }
            leftBarButtonItems = [view]
        }
        get {
            return leftBarButtonItems.first
        }
    }
    
    public var rightBarButtonItem : UIView? {
        set {
            guard let view = newValue else { return }
            rightBarButtonItems = [view]
        }
        get {
            return rightBarButtonItems.first
        }
    }
    
    
    
    override func makeUI() {
        super.makeUI()
        setupUI()
    }
    
    
    private func setupUI() {
        
        backgroundColor = .white
        
        
        addSubview(rightView)
        addSubview(leftView)
        
        
        
        /// 方案一: title 左对齐
        // /**
        
         leftView.snp.makeConstraints { (make) in
             make.left.bottom.equalTo(self)
             make.height.equalTo(44)
         }
         
         rightView.snp.makeConstraints { (make) in
             make.bottom.right.equalTo(self)
             make.height.equalTo(leftView.snp.height)
             make.left.equalTo(leftView.snp.right)
             make.width.equalTo(leftView.snp.width)
         }
         //*/
        
        /// 方案二: title 居中对齐
//        addSubview(leftView)
//        titleLabel.snp.makeConstraints { (make) in
//            make.centerX.equalTo(self)
//            make.width.greaterThanOrEqualTo(40)
//            make.height.equalTo(44)
//            make.bottom.equalTo(snp.bottom).offset(-4)
//        }
//        leftView.snp.makeConstraints { (make) in
//            make.height.centerY.equalTo(titleLabel)
//            make.left.equalTo(self)
//            make.right.equalTo(titleLabel.snp.left)
//        }
//
//        rightView.snp.makeConstraints { (make) in
//            make.height.centerY.equalTo(leftView)
//            make.right.equalTo(self)
//            make.left.equalTo(titleLabel.snp.right)
//        }
        
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var leftOffset : CGFloat  = contentInset.left
        for (index, view) in leftBarButtonItems.enumerated() {
            view.sizeToFit()
            view.frame = CGRect(x: index > 0 ? leftOffset + itemMargin : leftOffset, y: 0, width: view.frame.width, height: leftView.frame.height)
            leftOffset = view.frame.maxX
            leftView.addSubview(view)
        }
        
        if !rightBarButtonItems.isEmpty {
            var rightOffset : CGFloat  = rightView.width - contentInset.right
            for (index, view) in rightBarButtonItems.enumerated() {
                view.sizeToFit()
                rightOffset = (rightOffset - view.frame.width - (index > 0 ? itemMargin : 0))
                view.frame = CGRect(x: rightOffset, y: 0, width: view.frame.width, height: rightView.frame.height)
                rightView.addSubview(view)
            }
        }
    }
}
