//
//  SavedCollectionViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SavedCollectionViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection : Observable<SavedCollectionCellViewModel>
        let edit : Observable<Bool>
        let back : Observable<Bool>
    }
    
    struct Output {
        let items : Driver<[SectionModel<Void,SavedCollectionCellViewModel>]>
        let isEdit : Driver<Bool>
        let backButtonImage : Driver<UIImage?>
        let navigationTitle : Driver<String>
        let editButtonImage : Driver<UIImage?>
        let editButtonTitle : Driver<String?>
        let back : Driver<Void>
        let delete : Observable<SavedCollectionCellViewModel>
        let detail : Driver<DefaultColltionItem>
    }
    
    let element : BehaviorRelay<PageMapable<DefaultColltionItem>?> = BehaviorRelay(value: nil)
    let confirmDelete = PublishSubject<SavedCollectionCellViewModel>()
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SectionModel<Void,SavedCollectionCellViewModel>]>(value: [])
        let isEdit = BehaviorRelay<Bool>(value: false)
        let back = PublishSubject<Void>()
        let delete = PublishSubject<SavedCollectionCellViewModel>()
        
        let navigationTitle = isEdit.map { $0 ? "Edit Collection" : "All" }.asDriver(onErrorJustReturn: "")
        let backButtonImage = isEdit.map { $0 ? R.image.icon_navigation_close() : R.image.icon_navigation_back_black() }.asDriver(onErrorJustReturn: nil)
        let editButtonImage = isEdit.map { $0 ? nil : R.image.icon_navigation_edit() }.asDriver(onErrorJustReturn: nil)
        let editButtonTitle = isEdit.map { $0 ? "DONE" : nil }.asDriver(onErrorJustReturn: "")
        let detail = input.selection.filter { _ in !isEdit.value }.map { $0.item }.asDriver(onErrorJustReturn: DefaultColltionItem())
        
        
        input.edit.map { !$0 }.bind(to: isEdit).disposed(by: rx.disposeBag)
        input.back.subscribe(onNext: { i in
            if i == true {
                isEdit.accept(false)
            } else {
                back.onNext(())
            }
        }).disposed(by: rx.disposeBag)
        
        input.headerRefresh
            .flatMapLatest({ [weak self] () -> Observable<(RxSwift.Event<PageMapable<DefaultColltionItem>>)> in
                guard let self = self else {
                    return Observable.just(.error(ExceptionError.unknown))
                }
                isEdit.value ? isEdit.accept(false) : ()
                self.page = 1
                return self.provider.savedCollection(pageNum: self.page)
                    .trackError(self.error)
                    .trackActivity(self.headerLoading)
                    .materialize()
            }).subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let item):
                    self.element.accept(item)
                    self.refreshState.onNext(item.refreshState)
                case .error(let error):
                    guard let error = error.asExceptionError else { return }
                    switch error  {
                    default:
                        self.refreshState.onNext(.end)
                        logError(error.debugDescription)
                    }

                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        
        input.footerRefresh.flatMapLatest({ [weak self] () -> Observable<RxSwift.Event<PageMapable<DefaultColltionItem>>> in
            guard let self = self else {
                return Observable.just(.error(ExceptionError.unknown))
            }
            self.page += 1
            return self.provider.savedCollection(pageNum: self.page)
                .trackActivity(self.footerLoading)
                .trackError(self.error)
                .materialize()
        }).subscribe(onNext: { [weak self](event) in
            guard let self = self else { return }
            switch event {
            case .next(let item):
                var temp = item
                temp.list = (self.element.value?.list ?? []) + item.list
                self.element.accept(temp)
                self.refreshState.onNext(item.refreshState)
            case .error(let error):
                guard let error = error.asExceptionError else { return }
                switch error  {
                default:
                    self.page -= 1
                    self.refreshState.onNext(.end)
                    logError(error.debugDescription)
                }

            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        element.filterNil().map { items -> [SectionModel<Void,SavedCollectionCellViewModel>] in
            let sectionItems = items.list.map { item -> SavedCollectionCellViewModel  in
                let viewModel = SavedCollectionCellViewModel(item: item)
                viewModel.delete.map { viewModel }.bind(to: delete).disposed(by: self.rx.disposeBag)
                isEdit.map { !$0}.bind(to: viewModel.deleteButtonHidden).disposed(by: self.rx.disposeBag)
                return viewModel
            }
            let sections = [SectionModel<Void,SavedCollectionCellViewModel>(model: (), items: sectionItems)]
            return sections
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        confirmDelete.flatMapLatest({ [weak self] (cellViewModel) -> Observable<(RxSwift.Event<(SavedCollectionCellViewModel,Bool)>)> in
            guard let self = self else { return Observable.just(RxSwift.Event.completed) }
            var params = [String : Any]()
            params["type"] = cellViewModel.item.type?.rawValue ?? -1
            params["updateSaved"] = false
            params.merge(dict: cellViewModel.item.id)
            return self.provider.saveCollection(param: params)
                .trackError(self.error)
                .trackActivity(self.loading)
                .map { (cellViewModel, $0)}
                .materialize()
        }).subscribe(onNext: {  event in
            switch event {
            case .next(let (cellViewModel,result)):
                if !result {
                    var section = elements.value[0]
                    section.items.removeFirst(where: { $0.item == cellViewModel.item})
                    elements.accept([section])
                }
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        return Output(items: elements.asDriver(onErrorJustReturn: []),
                      isEdit: isEdit.asDriver(onErrorJustReturn: false),
                      backButtonImage: backButtonImage,
                      navigationTitle: navigationTitle,
                      editButtonImage: editButtonImage,
                      editButtonTitle: editButtonTitle,
                      back: back.asDriver(onErrorJustReturn: ()),
                      delete: delete.asObservable(),
                      detail: detail)
    }
}
