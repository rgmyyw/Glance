//
//  DefaultTableViewCellViewModel.swift
//  
//
//  Created by yanghai on 6/23/19.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol CellViewModelProtocol {
    
    associatedtype Item
    var item: Item { get }
    init(item : Item)
}


class CellViewModel<T>:  CellViewModelProtocol {
    
    typealias Item = T
    var item: T
    
    required init(item: T) {
        self.item = item
    }
}
