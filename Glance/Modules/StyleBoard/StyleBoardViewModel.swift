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
        let next : Observable<Void>
    }
    
    struct Output {
        let currentProducts : Driver<[StyleBoardSection]>
        let add : Driver<Void>
    }
    
    let selection = PublishSubject<[Home]>()
    let selected : BehaviorRelay<[Home]> = BehaviorRelay(value: [])
        
    

    
    func transform(input: Input) -> Output {
        

        let elements = BehaviorRelay<[StyleBoardSection]>(value: [])
        let add = PublishSubject<Void>()
        let delete = PublishSubject<StyleBoardSectionItem>()
        let currentImages = selected.map { $0.map { Observable.just($0.image?.url)} }.asDriver(onErrorJustReturn: [])
        
        selection.map { $0 + elements.value[0].items.map { $0.viewModel.item }.filterDuplicates { $0.productId }  }.bind(to: selected).disposed(by: rx.disposeBag)

        
        selected.map { i -> [StyleBoardSection] in
            var items = i
            if i.isNotEmpty { items.removeLast() }
            let elements = items.enumerated().map { (offset, item) -> StyleBoardSectionItem in
                let viewModel = StyleBoardImageCellViewModel(item: item)
                let item = StyleBoardSectionItem.image(identity: offset.string, viewModel: viewModel)
                viewModel.delete.map { item }.bind(to: delete).disposed(by: self.rx.disposeBag)
                return item
            }
            let viewModel = StyleBoardImageCellViewModel(item: Home(productId: "-1"))
            let empty = StyleBoardSectionItem.image(identity: "-1", viewModel: viewModel)
            viewModel.add.bind(to: add).disposed(by: self.rx.disposeBag)

            return [StyleBoardSection.images(items: elements + [empty])]
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        delete.subscribe(onNext: { (item) in
            let section = elements.value[0]
            var items = section.items
            items.removeFirst(item)
            elements.accept([StyleBoardSection.init(original: section, items: items)])
        }).disposed(by: rx.disposeBag)
        
        
        return Output(currentProducts: elements.asDriver(onErrorJustReturn: []),
                      add: add.asDriver(onErrorJustReturn: ()))
    }
}

