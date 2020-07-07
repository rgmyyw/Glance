//
//  UserViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/7.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import WMZPageController

class UserViewController: ViewController {
    
    override func makeUI() {
        super.makeUI()
        
                
        let insight = UIButton()
        insight.setImage(R.image.icon_navigation_insight(), for: .normal)
        insight.sizeToFit()
        navigationBar.leftBarButtonItem = insight
        
        
        let setting  = UIButton()
        setting.setImage(R.image.icon_navigation_setting(), for: .normal)
        setting.sizeToFit()
        
        let share  = UIButton()
        share.setImage(R.image.icon_navigation_share(), for: .normal)
        share.sizeToFit()
        navigationBar.rightBarButtonItems = [setting,share]

                
        let pageViewContrller = UserPageController()
        stackView.addArrangedSubview(pageViewContrller.view)
        addChild(pageViewContrller)
    }
}
 
private class UserPageController: WMZPageController {
    
    var titleDatas = ["asdas","asdas","asdas","asdas","asdas"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vcs = titleDatas.map { vc -> UIViewController in
            let vc = UIViewController()
            vc.view.backgroundColor = .random
            return vc
        }
                
        let param = PageParam()
        param.wTitleArr = titleDatas
        param.wControllers = vcs
        param.wTopSuspension = true
        param.wBounces = true
        param.wFromNavi =  true
        param.wMenuHeadView = {
            let view = UIView()
            view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 400))
            view.backgroundColor = .random
            return view
        }
        
        self.param = param
    }
    
}



 
