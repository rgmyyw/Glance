//
//  Demo2ViewController.swift
//  
//
//  Created by 杨海 on 2020/5/5.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class Demo2ViewController: UIViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func close() {
           dismiss(animated: true, completion: nil)
       }
       
    deinit {
        print(self)
    }


}
