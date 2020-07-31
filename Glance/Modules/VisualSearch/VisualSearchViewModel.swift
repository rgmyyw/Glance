//
//  VisualSearchViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/28.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class VisualSearchViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let currentRect : Observable<CGRect>
    }
    struct Output {
        let imageURI : Driver<String>
        let currentRect : Driver<CGRect>
    }
    
    let image : BehaviorRelay<UIImage>
    
    init(provider: API, image : UIImage) {
        self.image = BehaviorRelay(value: image)
        super.init(provider: provider)
    }


    func transform(input: Input) -> Output {
        
        let imageURI = PublishSubject<String>()
        let currentRect = PublishSubject<CGRect>()
        
        image.flatMapLatest({ [weak self] (image) -> Observable<(RxSwift.Event<(String)>)> in
                guard let self = self else { return Observable.just(RxSwift.Event.completed) }
                guard let data = image.jpegData(compressionQuality: 0.1) else { return  Observable.just(RxSwift.Event.completed) }
            return self.provider.uploadImage(type: UploadImageType.visualSearch.rawValue, size: image.size, data: data)
                    .trackActivity(self.loading)
                    .trackError(self.error)
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (url)):
                    imageURI.onNext(url)
                    input.currentRect.bind(to: currentRect).disposed(by: self.rx.disposeBag)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        

        return Output(imageURI: imageURI.asDriver(onErrorJustReturn: ""),
                      currentRect: currentRect.asDriver(onErrorJustReturn: .zero))
    }
}
