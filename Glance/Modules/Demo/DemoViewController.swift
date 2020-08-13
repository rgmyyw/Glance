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
        
        
        guard let provider = self.viewModel?.provider else {
            return
        }
        
//        let viewModel = PostsDetailViewModel(provider: self.viewModel!.provider, item: Home())
//        self.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        //needSignUp.onNext(())
        
//        
//        let viewModel = PostProductViewModel(provider: self.viewModel!.provider, image: UIImage(named:"1.png" ), taggedItems: [])
//            self.navigator.show(segue: .postProduct(viewModel: viewModel), sender: self)
        
        
//        let viewModel = StyleBoardViewModel(provider: provider)
//        self.navigator.show(segue: .styleBoard(viewModel: viewModel), sender: self)
                
                
        
        let viewModel = StyleBoardSearchViewModel(provider: provider)
        self.navigator.show(segue: .styleBoardSearch(viewModel: viewModel), sender: self)

    }
       
    override func makeUI() {
        super.makeUI()
        
        navigationBar.title = "Chat Inbox"
        stackView.addArrangedSubview(containerView)
    }

    
    
    

}
