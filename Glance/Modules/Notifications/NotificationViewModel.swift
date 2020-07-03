//
//  NoticeViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NoticeViewModel: ViewModel, ViewModelType {
        
    struct Input {
        let selection: Observable<NoticeCellViewModel>
    }

    struct Output {
        let items : Driver<[NoticeCellViewModel]>
        let saved : Driver<Void>
    }
    
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[NoticeCellViewModel]>(value: [])
        let items = (0...10).map { _  -> NoticeCellViewModel in
            return NoticeCellViewModel(item: Notice())
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
