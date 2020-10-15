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
import MJRefresh


enum RefreshComponent {
    case `default`
    case header
    case footer
    case none
}

class TableViewController: ViewController, UIScrollViewDelegate {
    
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)
    
    let noMoreData = PublishSubject<Void>()
    let refreshComponent = BehaviorRelay<RefreshComponent>(value: .default)
    
    var viewDidLoadBeginRefresh : Bool = true
    
    
    private let style : UITableView.Style
    
    lazy var tableView: TableView = {
        let view = TableView(frame: .zero, style: style)
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func makeUI() {
        super.makeUI()
        
        stackView.spacing = 0
        stackView.insertArrangedSubview(tableView, at: 0)
        
        noMoreData.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] () in
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }).disposed(by: rx.disposeBag)
        
        refreshComponent.subscribe(onNext: { [weak self] (component) in
            switch component {
            case .default:
                self?.setupHeaderRefresh()
                self?.setupFooterRefresh()
            case .header:
                self?.setupHeaderRefresh()
                self?.tableView.mj_footer = nil
            case .footer:
                self?.viewDidLoadBeginRefresh = false
                self?.setupFooterRefresh()
                self?.tableView.mj_header = nil
            case .none:
                self?.viewDidLoadBeginRefresh = false
                self?.tableView.mj_header = nil
                self?.tableView.mj_footer = nil
            }
            
        }).disposed(by: rx.disposeBag)
        
        Observable.zip(rx.viewDidAppear,Observable.just(()))
            .mapToVoid().delay(RxTimeInterval.microseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self]() in
                if self?.viewDidLoadBeginRefresh == true {
                    self?.tableView.mj_header?.beginRefreshing()
                }
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
    
    func setupHeaderRefresh() {
        
        let normalHeader = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            if let footer = self?.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                footer.isHidden = true
                footer.resetNoMoreData()
            }
            self?.headerRefreshTrigger.onNext(())
        })
        normalHeader.lastUpdatedTimeLabel?.isHidden = true
        
        tableView.mj_header = normalHeader
    }
    func setupFooterRefresh() {
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        tableView.mj_footer?.isHidden = true
    }

    
    override func viewDidLayoutSubviews() {
        tableView.contentInset = .zero
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
        viewModel?.refreshState
            .subscribe(onNext: { [weak self](state) in
            switch state {
            case .enable:
                self?.tableView.mj_footer?.isHidden = false
            case .disable:
                self?.tableView.mj_footer?.isHidden = true
            case .end:
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.mj_footer?.endRefreshing()
            case .noMoreData:
                self?.tableView.mj_footer?.isHidden = false
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            case .begin:
                if self?.tableView.mj_header?.isRefreshing == true {
                    self?.tableView.mj_header?.endRefreshing()
                }
                self?.tableView.mj_header?.beginRefreshing()

            }
        }).disposed(by: rx.disposeBag)

        
        if let header = tableView.mj_header {
            isHeaderLoading.bind(to: header.rx.isAnimating).disposed(by: rx.disposeBag)
        }
        if let footer = tableView.mj_footer  {
            isFooterLoading.bind(to: footer.rx.isAnimating).disposed(by: rx.disposeBag)
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
