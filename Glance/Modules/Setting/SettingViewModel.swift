//
//  SettingView.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel: ViewModel, ViewModelType {

    struct Input {
    }

    struct Output {
    }

    let selectedItem = PublishSubject<SettingItem>()

    func transform(input: Input) -> Output {

        return Output()
    }
}
