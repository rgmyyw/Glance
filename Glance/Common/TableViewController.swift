//
//  TableViewController.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KafkaRefresh
import Toast_Swift


class TableViewController: ViewController, UIScrollViewDelegate {
    
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)
    
    let noMoreData = PublishSubject<Void>()
    
    private let style : UITableView.Style
    
    lazy var tableView: TableView = {
        let view = TableView(frame: .zero, style: style)
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.estimatedRowHeight = UITableView.automaticDimension
        //        view.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        view.rx.setDelegate(self).disposed(by: rx.disposeBag)
        return view
    }()
    
    init(viewModel: ViewModel?, navigator: Navigator, tableView style : UITableView.Style = .plain) {
        self.style = style
        super.init(viewModel: viewModel, navigator: navigator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.style = .plain
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    
    override func makeUI() {
        super.makeUI()
        
        stackView.spacing = 0
        stackView.insertArrangedSubview(tableView, at: 0)
        
        tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.tableView.footRefreshControl.resumeRefreshAvailable()
            self?.headerRefreshTrigger.onNext(())
        })
        
        tableView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        
        
        tableView.footRefreshControl.setAlertBackgroundColor(view.backgroundColor)
        tableView.footRefreshControl.autoRefreshOnFoot = true
        
        
        noMoreData.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] () in
                guard let footRefreshControl = self?.tableView.footRefreshControl  else { return }
                footRefreshControl.endRefreshingAndNoLongerRefreshing(withAlertText: "- No more update -")
            }).disposed(by: rx.disposeBag)
        
        
        
        
        let updateEmptyDataSet = Observable.of(isLoading.mapToVoid().asObservable(),
                                               emptyDataViewDataSource.enable.mapToVoid(),
                                               emptyDataViewDataSource.title.filterNil().mapToVoid(),
                                               emptyDataViewDataSource.subTitle.filterNil().mapToVoid(),
                                               emptyDataViewDataSource.image.filterNil().mapToVoid(),
                                               emptyDataViewDataSource.buttonTitle.filterNil().mapToVoid(),
                                               languageChanged.asObservable()).merge()
        updateEmptyDataSet.subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadEmptyDataSet()
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        emptyDataView.snp.makeConstraints { (make) in
            make.size.equalTo(tableView.frame.size)
        }
        emptyDataView.setNeedsLayout()
        emptyDataView.layoutIfNeeded()
        tableView.reloadEmptyDataSet()
        super.viewDidLayoutSubviews()
    }

    
    override func bindViewModel() {
        super.bindViewModel()

        viewModel?.noMoreData.bind(to: noMoreData).disposed(by: rx.disposeBag)
        viewModel?.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel?.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
                
        if tableView.headRefreshControl != nil {
            isHeaderLoading.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind(to: tableView.headRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        }
        if tableView.footRefreshControl != nil {
            isFooterLoading.delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind(to: tableView.footRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        }

    }
    
    override func updateUI() {
        super.updateUI()
        
        emptyDataViewDataSource.contentInsetTop.accept(tableView.contentInset.top)
    }
}

extension TableViewController {
    
    func deselectSelectedRow() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            selectedIndexPaths.forEach({ (indexPath) in
                tableView.deselectRow(at: indexPath, animated: false)
            })
        }
    }
}


extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.font = UIFont(name: ".SFUIText-Bold", size: 15.0)!
            themeService.rx
                .bind({ $0.text }, to: view.textLabel!.rx.textColor)
                .bind({ $0.background }, to: view.contentView.rx.backgroundColor)
                .disposed(by: rx.disposeBag)
        }
    }
}
