//
//  CollectionViewController.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KafkaRefresh

class CollectionViewController: ViewController, UIScrollViewDelegate {
    
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)
    
    let hasData = PublishSubject<Bool>()
    
    
    lazy var collectionView: CollectionView = {
        let view = CollectionView()
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.alwaysBounceVertical = true
        view.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func makeUI() {
        super.makeUI()
        
        stackView.spacing = 0        
        stackView.insertArrangedSubview(collectionView, at: 0)
        
        collectionView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        
        collectionView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        
        collectionView.footRefreshControl.setAlertBackgroundColor(view.backgroundColor)
        collectionView.footRefreshControl.autoRefreshOnFoot = true
                
        
        hasData.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (hasData) in
                guard let footRefreshControl = self?.collectionView.footRefreshControl  else { return }
                if !hasData {
                    footRefreshControl.endRefreshingAndNoLongerRefreshing(withAlertText: "No more ...")
                } else {
                    footRefreshControl.resumeRefreshAvailable()
                }
            }).disposed(by: rx.disposeBag)
        
        let updateEmptyDataSet = Observable.of(isLoading.mapToVoid().asObservable(),
                                               emptyDataViewDataSource.title.filterNil().mapToVoid(),
                                               emptyDataViewDataSource.subTitle.filterNil().mapToVoid(),
                                               emptyDataViewDataSource.image.filterNil().mapToVoid(),
                                               emptyDataViewDataSource.buttonTitle.filterNil().mapToVoid(),
                                               languageChanged.asObservable()).merge()
        
        updateEmptyDataSet.subscribe({ [weak self] (_) in
            self?.collectionView.reloadEmptyDataSet()
        }).disposed(by: rx.disposeBag)
        

        
        
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        if collectionView.headRefreshControl != nil {
            isHeaderLoading.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind(to: collectionView.headRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        }
        if collectionView.footRefreshControl != nil {
            isFooterLoading.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind(to: collectionView.footRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        }
    }
    
    override func updateUI() {
        super.updateUI()
        
        emptyDataViewDataSource.contentInsetTop.accept(collectionView.contentInset.top)
    }
}
