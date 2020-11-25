//
//  StyleBoardSearchViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class StyleBoardSearchViewModel: ViewModel, ViewModelType {

    struct Input {
        let add: Observable<Void>
    }

    struct Output {
        let config: Driver<[StyleBoardSearchModuleItem]>
        let placeholder: Driver<String>
        let addButtonEnable: Driver<Bool>
        let upload: Driver<Void>
        let complete: Driver<Void>
    }

    let textInput = BehaviorRelay<String>(value: "")
    let element: BehaviorRelay<PageMapable<DefaultColltionItem>?> = BehaviorRelay(value: nil)
    let selection = PublishSubject<[DefaultColltionItem]>()

    func transform(input: Input) -> Output {

        let placeholder = Observable.just("Search")
        let selected = BehaviorRelay<[[DefaultColltionItem]]>(value: [[], [], []])
        let addButtonEnable = selected.map { $0.flatMap { $0}}.map { $0.isNotEmpty }
        let upload = PublishSubject<Void>()
        let complete = selection.mapToVoid().merge(with: NotificationCenter.default.rx.notification(.kAddProduct).mapToVoid())

        input.add.flatMapLatest { () -> Observable<[DefaultColltionItem]> in
            let elements = selected.value.flatMap { $0}
            return Observable.just(elements)
        }.bind(to: selection).disposed(by: rx.disposeBag)

        let config = Observable<[StyleBoardSearchModuleItem]>.create { (observer) -> Disposable in
            let element = (0..<3).map { type -> StyleBoardSearchContentViewModel in
                let i = StyleBoardSearchContentViewModel(provider: self.provider, type: type)
                i.upload.bind(to: upload).disposed(by: self.rx.disposeBag)
                self.textInput.bind(to: i.textInput).disposed(by: self.rx.disposeBag)
                i.selection.subscribe(onNext: { (elements) in
                    var e = selected.value
                    e[type] = elements
                    selected.accept(e)
                }).disposed(by: self.rx.disposeBag)
                return i
            }
            observer.onNext([.save(viewModel: element[0]),
                             .post(viewModel: element[1]),
                             .app(viewModel: element[2])])
            observer.onCompleted()
            return Disposables.create { }
        }

        return Output(config: config.asDriver(onErrorJustReturn: []),
                      placeholder: placeholder.asDriver(onErrorJustReturn: ""),
                      addButtonEnable: addButtonEnable.asDriver(onErrorJustReturn: false),
                      upload: upload.asDriverOnErrorJustComplete(),
                      complete: complete.asDriverOnErrorJustComplete())
    }
}
