//
//  BlockedListViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BlockedListViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let selection: Observable<BlockedCellViewModel>
    }
    
    struct Output {
        let items : Driver<[BlockedCellViewModel]>
        let saved : Driver<Void>
    }
    
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[BlockedCellViewModel]>(value: [])
        let items = (0...10).map { _  -> BlockedCellViewModel in
            return BlockedCellViewModel(item: Notice())
        }
        elements.accept(items)
        let saved = PublishSubject<Void>()
        
        input.selection.subscribe(onNext: { item in
            elements.value.forEach { (i) in i.selected.accept(false) }
            item.selected.accept(true)
            saved.onNext(())
        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      saved:saved.asDriver(onErrorJustReturn: ()))
    }
}
