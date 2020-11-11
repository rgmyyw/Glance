//
//  KafkaRefresh+Rx.swift
//  
//
//  Created by yanghai on 7/24/18.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import MJRefresh


extension Reactive where Base: MJRefreshComponent {

    public var isAnimating: Binder<Bool> {
        return Binder(self.base) { refreshControl, active in
            if active {
                
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}
