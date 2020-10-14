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
import MJRefresh

class CollectionViewController: ViewController, UIScrollViewDelegate {
    
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)
    
    let noMoreData = PublishSubject<Void>()
    let refreshComponent = BehaviorRelay<RefreshComponent>(value: .default)
    

    var viewDidLoadBeginRefresh : Bool = true
    
    lazy var collectionView: CollectionView = {
        let view = CollectionView()
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.alwaysBounceVertical = true
        view.contentInset = .zero
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
                
        refreshComponent.subscribe(onNext: { [weak self] (component) in
            switch component {
            case .default:
                self?.setupHeaderRefresh()
                self?.setupFooterRefresh()
            case .header:
                self?.setupHeaderRefresh()
                self?.collectionView.mj_footer = nil
            case .footer:
                self?.viewDidLoadBeginRefresh = false
                self?.setupFooterRefresh()
                self?.collectionView.mj_header = nil
            case .none:
                self?.viewDidLoadBeginRefresh = false
                self?.collectionView.mj_header = nil
                self?.collectionView.mj_footer = nil
            }
            
        }).disposed(by: rx.disposeBag)

        Observable.zip(rx.viewDidAppear,Observable.just(()))
            .mapToVoid().delay(RxTimeInterval.microseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self]() in
                if self?.viewDidLoadBeginRefresh == true {
                    UIView.performWithoutAnimation {
                        self?.collectionView.mj_header?.beginRefreshing()
                    }
                }
        }).disposed(by: rx.disposeBag)

        noMoreData.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] () in
                self?.collectionView.mj_footer?.endRefreshingWithNoMoreData()
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
    
    
    func setupHeaderRefresh() {
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            if let footer = self?.collectionView.mj_footer as? MJRefreshAutoNormalFooter {
                footer.isHidden = true
                footer.resetNoMoreData()
            }
            self?.headerRefreshTrigger.onNext(())
        })
    }
    func setupFooterRefresh() {
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        collectionView.mj_footer?.isHidden = true
    }

    
    override func viewDidLayoutSubviews() {
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        emptyDataView.snp.makeConstraints { (make) in
            make.size.equalTo(collectionView.frame.size)
        }
        emptyDataView.setNeedsLayout()
        emptyDataView.layoutIfNeeded()
        collectionView.reloadEmptyDataSet()
        super.viewDidLayoutSubviews()
    }
        
    
    override func bindViewModel() {
        super.bindViewModel()
        
        viewModel?.noMoreData.bind(to: noMoreData).disposed(by: rx.disposeBag)
        viewModel?.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel?.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel?.refreshState.delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self](state) in
            switch state {
            case .enable:
                self?.collectionView.mj_footer?.isHidden = false
            case .disable:
                self?.collectionView.mj_footer?.isHidden = true
            case .end:
                self?.collectionView.mj_header?.endRefreshing()
                self?.collectionView.mj_footer?.endRefreshing()
            case .noMoreData:
                self?.collectionView.mj_footer?.isHidden = false
                self?.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            case .begin:
                if self?.collectionView.mj_header?.isRefreshing == true {
                    self?.collectionView.mj_header?.endRefreshing()
                }
                self?.collectionView.mj_header?.beginRefreshing()
            }
        }).disposed(by: rx.disposeBag)
        
        if let header = collectionView.mj_header {
            isHeaderLoading.bind(to: header.rx.isAnimating).disposed(by: rx.disposeBag)
        }
        if let footer = collectionView.mj_footer  {
            isFooterLoading.bind(to: footer.rx.isAnimating).disposed(by: rx.disposeBag)
        }
    }
    
    override func updateUI() {
        super.updateUI()
        
        emptyDataViewDataSource.contentInsetTop.accept(collectionView.contentInset.top)
    }
}
