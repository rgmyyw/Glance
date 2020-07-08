//
//  UserViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserViewModel: ViewModel, ViewModelType {
    
    struct Input {
    }
    
    struct Output {
    }
    
    let settingSelectedItem = PublishSubject<SettingItem>()

    func transform(input: Input) -> Output {
        
        return Output()
    }
}

