//
//  NavigationBar.swift
//  
//
//  Created by 杨海 on 2020/5/11.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class NavigationBar: UIView {
    
    public let lineView = View()
    public let titleLabel = Label()
    
    
    
    public var leftBarButtonItems : [UIView] = []
    public var leftBarButtonItem : UIView?  {
        set {
            guard let view = newValue else { return }
            leftBarButtonItems = [view]
        }
        get {
            return leftBarButtonItems.first
        }
    }
    public var rightBarButtonItems : [UIView] = []
    public var rightBarButtonItem : UIView? {
        set {
            guard let view = newValue else { return }
            rightBarButtonItems = [view]
        }
        get {
            return rightBarButtonItems.first
        }
    }
    public var contentInset : UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    private lazy var leftView : View = View()
    private lazy var rightView : View = View()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        
        backgroundColor = UIColor.white
        
        addSubview(lineView)
        addSubview(titleLabel)
        addSubview(leftView)
        addSubview(rightView)
    
        
        lineView.backgroundColor = UIColor.lightGray
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.titleFont(18)
        titleLabel.textColor = UIColor.text()
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.width.greaterThanOrEqualTo(40)
            make.height.equalTo(44)
            make.bottom.equalTo(lineView.snp.top)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        
        leftView.snp.makeConstraints { (make) in
            make.height.centerY.equalTo(titleLabel)
            make.left.equalTo(self)
            make.right.equalTo(titleLabel.snp.left)
        }
        
        rightView.snp.makeConstraints { (make) in
            make.height.centerY.equalTo(leftView)
            make.right.equalTo(self)
            make.left.equalTo(titleLabel.snp.right)
        }
        
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var leftOffset : CGFloat  = contentInset.left
        for view in leftBarButtonItems {
            view.frame = CGRect(x: leftOffset, y: 0, width: view.frame.width, height: leftView.frame.height)
            leftOffset = view.frame.maxX
            leftView.addSubview(view)
        }
        
        if !rightBarButtonItems.isEmpty {
            
            var rightOffset : CGFloat  = rightView.width - contentInset.right
            for view in rightBarButtonItems {
                rightOffset = (rightOffset - view.frame.width)
                view.frame = CGRect(x: rightOffset, y: 0, width: view.frame.width, height: rightView.frame.height)
                rightView.addSubview(view)
            }
        }
    }
}
