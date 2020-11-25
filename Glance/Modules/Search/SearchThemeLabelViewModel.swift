//
//  SearchThemeViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchThemeLabelViewModel: ViewModel, ViewModelType {

    struct Input {
        let refresh: Observable<Void>
    }

    struct Output {
        let config: Driver<[SearchThemeLabelModuleItem]>
        let updateHeadLayout: Driver<Void>
        let themeTitle: Driver<String>
    }

    let label: BehaviorRelay<SearchThemeDetailLabel>

    init(provider: API, label: SearchThemeDetailLabel) {
        self.label = BehaviorRelay(value: label)
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {

        let themeTitle = label.map { $0.name ?? "" }.asDriver(onErrorJustReturn: "")
        let updateHeadLayout = PublishSubject<Void>()

        let config = label.map { $0.labelId }.map { (labelId) -> [SearchThemeLabelModuleItem] in
            let all = SearchThemeLabelContentViewModel(provider: self.provider, type: .all, labelId: labelId)
            let product = SearchThemeLabelContentViewModel(provider: self.provider, type: .product, labelId: labelId)
            let post = SearchThemeLabelContentViewModel(provider: self.provider, type: .post, labelId: labelId)
            let items: [SearchThemeLabelModuleItem] = [.all(viewModel: all), .product(viewModel: product), .post(viewModel: post)]
            return items
        }

        label.mapToVoid().delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).bind(to: updateHeadLayout).disposed(by: rx.disposeBag)

        return Output(config: config.asDriver(onErrorJustReturn: []),
                      updateHeadLayout: updateHeadLayout.asDriver(onErrorJustReturn: ()),
                      themeTitle: themeTitle
        )
    }

}
