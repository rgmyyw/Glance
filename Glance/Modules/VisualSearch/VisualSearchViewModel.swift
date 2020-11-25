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

enum VisualSearchMode {

    case post
    case preview

    var searchHidden: Bool {
        switch self {
        case .preview:
            return true
        case .post:
            return false
        }
    }

    var descriptionTitle: String {
        switch self {
        case .preview:
            return "Similar Styles"
        case .post:
            return "Suggested Products"
        }
    }

}

class VisualSearchViewModel: ViewModel, ViewModelType {

    struct Input {
        let currentBox: Observable<Box>
        let commit: Observable<Void>
    }
    struct Output {
        let imageURI: Driver<String>
        let current: Driver<Box>
        let post: Observable<(image: UIImage, items: [DefaultColltionItem])>
        let dots: Driver<[VisualSearchDotCellViewModel]>
        let selection: Driver<VisualSearchDotCellViewModel>
    }

    let image: BehaviorRelay<UIImage>
    let mode: BehaviorRelay<VisualSearchMode>
    let reselection = PublishSubject<DefaultColltionItem>()
    let dots = BehaviorRelay<[VisualSearchDotCellViewModel]>(value: [])

    init(provider: API, image: UIImage, mode: VisualSearchMode = .preview) {
        self.image = BehaviorRelay(value: image)
        self.mode = BehaviorRelay(value: mode)
        super.init(provider: provider)

    }

    func transform(input: Input) -> Output {

        let imageURI = PublishSubject<String>()
        let currentBox = PublishSubject<Box>()
        let selection = PublishSubject<VisualSearchDotCellViewModel>()
        let post = input.commit.map { () -> (image: UIImage, items: [DefaultColltionItem]) in
            let image = self.image.value
            let items = self.dots.value.compactMap { $0.selected }
            return (image : image, items : items)
        }

        reselection.map { i -> VisualSearchDotCellViewModel? in
            let values = self.dots.value
            return values.filter { $0.selected == i}.first
        }.filterNil().bind(to: selection).disposed(by: rx.disposeBag)

        image.delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .flatMapLatest({ [weak self] (image) -> Observable<(RxSwift.Event<(String)>)> in
                guard let self = self else { return .error(ExceptionError.unknown) }
                guard let data = image.jpegData(compressionQuality: 0.1) else {
                    return  .error(ExceptionError.general("image compression error"))
                }
                return self.provider.uploadImage(type: UploadImageType.visualSearch.rawValue, size: image.size, data: data)
                    .trackActivity(self.loading)
                    .trackError(self.error)
                    .materialize()
            }).subscribe(onNext: { event in
                switch event {
                case .next(let (url)):
                    imageURI.onNext(url)
                    input.currentBox.bind(to: currentBox).disposed(by: self.rx.disposeBag)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error {
                    default:
                        logError(error.debugDescription)
                    }
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)

        return Output(imageURI: imageURI.asDriver(onErrorJustReturn: ""),
                      current: currentBox.asDriver(onErrorJustReturn: .zero),
                      post: post,
                      dots: dots.asDriver(onErrorJustReturn: []),
                      selection: selection.asDriverOnErrorJustComplete())
    }
}
