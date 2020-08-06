//
//  DemoViewController.swift
//  Popupable_Example
//
//  Created by 杨海 on 2020/5/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import PopupDialog


class DemoViewController: ViewController {    
    
    @IBOutlet weak var containerView: UIView!
    @IBAction func click() {
        
//        let viewModel = PostsDetailViewModel(provider: self.viewModel!.provider, item: Home())
//        self.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        //needSignUp.onNext(())
        
//        
//        let viewModel = AddProductViewModel(provider: self.viewModel!.provider, image: <#UIImage#>)
//            self.navigator.show(segue: .addProduct(viewModel: viewModel), sender: self)
        
    }
       
    override func makeUI() {
        super.makeUI()
        
        navigationBar.title = "Chat Inbox"
        stackView.addArrangedSubview(containerView)
    }

    
    
    

}
