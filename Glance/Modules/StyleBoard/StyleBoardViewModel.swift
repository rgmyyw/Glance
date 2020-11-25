//
//  StyleBoardViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StyleBoardViewModel: ViewModel, ViewModelType {

    struct Input {
        let next: Observable<Void>
        let selection: Observable<StyleBoardImageCellViewModel>
    }

    struct Output {
        let items: Driver<[StyleBoardSection]>
        let add: Driver<Void>
        let nextButtonEnable: Driver<Bool>
        let generateImage: Driver<Void>
        let post: Driver<(image: UIImage, items: [DefaultColltionItem])>
        let selection: Driver<StyleBoardImageCellViewModel>

    }

    let selection = PublishSubject<[DefaultColltionItem]>()
    let element: BehaviorRelay<[DefaultColltionItem]> = BehaviorRelay(value: [])
    let image = PublishSubject<UIImage>()
    let reselection = PublishSubject<DefaultColltionItem>()
    let selected = BehaviorRelay<DefaultColltionItem?>(value: nil)
    let delete = PublishSubject<DefaultColltionItem>()

    func transform(input: Input) -> Output {

        let elements = BehaviorRelay<[StyleBoardSection]>(value: [])
        let add = PublishSubject<Void>()
        //let delete = PublishSubject<StyleBoardImageCellViewModel>()
        let nextButtonEnable = element.map { $0.isNotEmpty }

        let post = image.map { image -> (image: UIImage, items: [DefaultColltionItem]) in
            let values = self.element.value
            return (image, values)
        }

        element.map { i -> [StyleBoardSection] in
            var values = i.enumerated().map { (offset, item) -> StyleBoardSectionItem in
                let viewModel = StyleBoardImageCellViewModel(item: item)
                viewModel.delete.map { viewModel.item }.bind(to: self.delete).disposed(by: self.rx.disposeBag)
                if item == self.selected.value { viewModel.selected.accept(true) }
                let item = StyleBoardSectionItem.image(viewModel: viewModel)
                return item
            }
            let emptyViewModel = StyleBoardImageCellViewModel(item: DefaultColltionItem(productId: ""))
            let empty = StyleBoardSectionItem.image(viewModel: emptyViewModel)
            emptyViewModel.add.bind(to: add).disposed(by: self.rx.disposeBag)
            values.append(empty)
            return [StyleBoardSection.images(items: values)]
        }.bind(to: elements).disposed(by: rx.disposeBag)

        delete.subscribe(onNext: { [weak self](item) in
            var items = self?.element.value ?? []
            let index = items.firstIndex { $0 == item }
            if let index = index {
                items.remove(at: index)
                self?.element.accept(items)
            } else {
                print("not found")
            }
        }).disposed(by: rx.disposeBag)

        // 用户手动添加商品
        NotificationCenter.default.rx
            .notification(.kAddProduct)
            .map { $0.object as? (Box, DefaultColltionItem)}
            .filterNil()
            .map { [$0.1] }.bind(to: selection).disposed(by: rx.disposeBag)

        selection.map {
            ($0 + self.element.value).filterDuplicates { $0.productId }
        }.filterEmpty()
            .bind(to: element)
            .disposed(by: rx.disposeBag)

        let selection = reselection.map { item -> StyleBoardImageCellViewModel? in
            elements.value.first?.items.filter { $0.viewModel.item == item }.first?.viewModel
        }.filterNil().merge(with: input.selection)

        selection.subscribe(onNext: { [weak self](cellViewModel) in
            elements.value.first?.items.forEach { v in
                v.viewModel.selected.accept(false)
            }
            self?.selected.accept(cellViewModel.item)
            cellViewModel.selected.accept(true)
        }).disposed(by: rx.disposeBag)

        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      add: add.asDriver(onErrorJustReturn: ()),
                      nextButtonEnable: nextButtonEnable.asDriver(onErrorJustReturn: false),
                      generateImage: input.next.asDriverOnErrorJustComplete(),
                      post: post.asDriverOnErrorJustComplete(),
                      selection: selection.asDriverOnErrorJustComplete())
    }
}
