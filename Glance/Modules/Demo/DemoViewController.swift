//
//  DemoViewController.swift
//  Popupable_Example
//
//  Created by 杨海 on 2020/5/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import PopupDialog
import FloatingPanel


struct PersonStruct {
    // 指向类对象的指针
    let metaData: UnsafePointer<Int>
    let refCounts: __uint64_t
    var name: String
    let age: Int
}

class Person {
    var name : String
    var age : Int
    init(name : String, age: Int) {
        self.name = name
        self.age = age
    }
}

class DemoViewController: ViewController , FloatingPanelControllerDelegate {

    
    @IBOutlet weak var containerView: UIView!
    @IBAction func click() {
        
        guard let provider = self.viewModel?.provider else {
            return
        }
        
        
        
//        let person = Person(name: "xioazhang", age: 10)
        
        
//        // 将指向person对象内存地址的指针转成指向PersonStruct结构体的指针，实则还是指向同一个内存地址
//        var pStructPointer = Unmanaged.passUnretained(person).toOpaque()
//            .bindMemory(to: PersonStruct.self, capacity: MemoryLayout.size(ofValue: person))
//
//        pStructPointer.pointee.name
        
//        print(pStructPointer)
        
                
//        let viewModel = VisualSearchViewModel(provider: provider, image: UIImage(named: "timg.jpeg")!)
//        self.navigator.show(segue: .visualSearch(viewModel: viewModel), sender: self,transition: .modal)

        
        //

//        let viewModel = SelectStoreViewModel(provider: provider, productId: "")
//        self.navigator.show(segue: .selectStore(viewModel: viewModel), sender: self,transition: .panel(style: .default))

        
//        let viewModel = PostsDetailViewModel(provider: self.viewModel!.provider, item: DefaultColltionItem())
//        self.navigator.show(segue: .dynamicDetail(viewModel: viewModel), sender: self)
        //needSignUp.onNext(())
        
//        
//        let viewModel = PostProductViewModel(provider: self.viewModel!.provider, image: UIImage(named:"1.png" ), taggedItems: [])
//            self.navigator.show(segue: .postProduct(viewModel: viewModel), sender: self)
        
        
//        let viewModel = StyleBoardViewModel(provider: provider)
//        self.navigator.show(segue: .styleBoard(viewModel: viewModel), sender: self)
                
                
        
//        let viewModel = StyleBoardSearchViewModel(provider: provider)
//        self.navigator.show(segue: .styleBoardSearch(viewModel: viewModel), sender: self)

    }
       
    override func makeUI() {
        super.makeUI()
        
        navigationBar.title = ""
        stackView.addArrangedSubview(containerView)
    }

    
    
    

}
