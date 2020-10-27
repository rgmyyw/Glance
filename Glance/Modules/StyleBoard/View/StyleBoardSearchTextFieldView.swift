//
//  StyleBoardSearchTextFieldView.swift
//  Glance
//
//  Created by yanghai on 2020/10/26.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class StyleBoardSearchTextFieldView: View {

    @IBOutlet weak var textField: UITextField!
    
    override func makeUI() {
        super.makeUI()
        
        textField.addPaddingLeft(12)
    }
}
