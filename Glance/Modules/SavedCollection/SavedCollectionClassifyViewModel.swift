//
//  SavedCollectionClassifyViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SavedCollectionClassifyViewModel: ViewModel, ViewModelType {
    
    struct Input {
    }
    
    struct Output {
        let total : Driver<String>
        let images : Driver<[Observable<URL?>]>
    }
    

    func transform(input: Input) -> Output {
        
        let element = BehaviorRelay<SavedCollection?>(value: nil)
        let total = element.filterNil().map { "\($0.savedCount) Saved"}.asDriver(onErrorJustReturn: "")
        let imagesURL = element.filterNil().map {  $0.imageList.map { Observable.just($0.url) } }.asDriver(onErrorJustReturn: [])
        
        
        Observable.just(())
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<SavedCollection>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                return self.provider.savedCollectionClassify()
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: {  event in
                switch event {
                case .next(let item):
                    element.accept(item)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        

        return Output(total: total, images: imagesURL)
    }
}

