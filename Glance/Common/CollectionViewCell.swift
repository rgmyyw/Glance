//
//  CollectionViewCell.swift
//  
//
//  Created by yanghai on 1/4/17.
//  Copyright © 2017 yanghai. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    func makeUI() {
        self.layer.masksToBounds = true
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }
}
