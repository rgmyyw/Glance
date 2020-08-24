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
        let currentBox : Observable<Box>
        let commit : Observable<Void>
    }
    struct Output {
        let imageURI : Driver<String>
        let currentBox : Driver<Box>
        let post : Observable<(image : UIImage, items : [(box : Box, item : Home)])>
        let updateBox : Observable<[(Bool,Box)]>
        let selectionBox : Observable<Box>
    }
    
    let image : BehaviorRelay<UIImage>
    
    let selected = BehaviorRelay<[(box : Box, item : Home)]>(value: [])
    let boxes = PublishSubject<[Box]>()
    let updateBox = PublishSubject<[(Bool,Box)]>()
    let selectionBox = PublishSubject<(box : Box, item : Home)>()
    
    
    init(provider: API, image : UIImage) {
        self.image = BehaviorRelay(value: image)
        super.init(provider: provider)
    }
    
    
    func transform(input: Input) -> Output {
        
        let imageURI = PublishSubject<String>()
        let currentBox = PublishSubject<Box>()
        let post = input.commit.map { (image : self.image.value, items : self.selected.value)}

        
        image.delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .flatMapLatest({ [weak self] (image) -> Observable<(RxSwift.Event<(String)>)> in
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
                    input.currentBox.bind(to: currentBox).disposed(by: self.rx.disposeBag)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        
        
        return Output(imageURI: imageURI.asDriver(onErrorJustReturn: ""),
                      currentBox: currentBox.asDriver(onErrorJustReturn: .zero),
                      post: post,
                      updateBox: updateBox.asObservable(),
                      selectionBox: selectionBox.map { $0.box}.asObservable())
    }
}
