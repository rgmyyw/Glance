//
//  SearchResultViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let refresh : Observable<Void>
        let search : Observable<Void>
    }
    
    struct Output {
        let config : Driver<[SearchResultModuleItem]>
        let search : Driver<String>
    }
    
    let text : BehaviorRelay<String>
    
    init(provider: API,text : String) {
        self.text = BehaviorRelay(value: text)
        super.init(provider: provider)
    }
    

    func transform(input: Input) -> Output {
                
        let config = Observable<[SearchResultModuleItem]>.create { (observer) -> Disposable in
            let all = SearchResultContentViewModel(provider: self.provider, type: .all)
            let product = SearchResultContentViewModel(provider: self.provider, type: .product)
            let post = SearchResultContentViewModel(provider: self.provider, type: .post)
            let user = SearchResultContentViewModel(provider: self.provider, type: .user)
            let items : [SearchResultModuleItem] = [.all(viewModel: all),.product(viewModel: product),.post(viewModel: post),.user(viewModel: user)]
            observer.onNext(items)
            observer.onCompleted()
            return Disposables.create { }
        }
        let search = input.search.map { self.text.value }.asDriver(onErrorJustReturn: "")
        
        return Output(config: config.asDriver(onErrorJustReturn: []),
                      search: search)
    }
}

