//
//  SearchViewController.swift
//  Glance
//
//  Created by yanghai on 2020/9/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WMZPageController

class SearchViewController: TableViewController , UITextFieldDelegate  {
    
    private lazy var customNavigationBar : SearchNavigationBar = SearchNavigationBar.loadFromNib(height: 44,width: self.view.width)

    let textFieldReturn = PublishSubject<Void>()
    
    override func makeUI() {
        super.makeUI()
        
        navigationBar.addSubview(customNavigationBar)

        tableView.register(nib: SearchCell.nib, withCellClass: SearchCell.self)
        tableView.mj_header = nil
        tableView.rowHeight = 44
        
        customNavigationBar.textField.delegate = self
        
        rx.viewDidAppear.mapToVoid()
            .bind(to: customNavigationBar.textField.rx.becomeFirstResponder)
            .disposed(by: rx.disposeBag)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SearchViewModel else { return }
        
        
        let cancel = customNavigationBar.cancelButton.rx.tap.asObservable()
        let selection = tableView.rx.modelSelected(SearchCellViewModel.self).asObservable()

        
        let input = SearchViewModel.Input(cancel: cancel,
                                          selection: selection,
                                          headerRefresh : headerRefreshTrigger.asObservable(),
                                          footerRefresh: footerRefreshTrigger.asObservable(),
                                          textFieldReturn: textFieldReturn.asObservable(),
                                          camera: customNavigationBar.cameraButton.rx.tap())
        let output = viewModel.transform(input: input)

        (customNavigationBar.textField.rx.textInput <-> viewModel.text).disposed(by: rx.disposeBag)
        output.items
            .drive(tableView.rx.items(cellIdentifier: SearchCell.reuseIdentifier, cellType: SearchCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
        }.disposed(by: rx.disposeBag)
        
        output.search.drive(onNext: { [weak self](text) in
            let result = SearchResultViewModel(provider: viewModel.provider, text: text)
            self?.navigator.show(segue: .searchResult(viewModel: result), sender: self)
        }).disposed(by: rx.disposeBag)
        
        output.close.drive(onNext: { [weak self]() in
            self?.navigator.dismiss(sender: self) 
        }).disposed(by: rx.disposeBag)
        
        output.viSearch.drive(onNext: { [weak self]() in
            ImagePickerManager.shared.showPhotoLibrary(sender: self, animate: true, configuration: { (config) in
                config.maxSelectCount = 1
                config.editAfterSelectThumbnailImage = true
                config.saveNewImageAfterEdit = false
                config.allowEditImage = false
            }) { [weak self] (images, assets, isOriginal) in
                guard let image = images?.first else { return }
                let viewModel = VisualSearchViewModel(provider: viewModel.provider, image: image)
                self?.navigator.show(segue: .visualSearch(viewModel: viewModel), sender: self,transition: .modal)
            }
        }).disposed(by: rx.disposeBag)

        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldReturn.onNext(())
        return true
    }
}
