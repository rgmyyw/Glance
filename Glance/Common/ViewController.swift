//
//  ViewController.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DZNEmptyDataSet
import NVActivityIndicatorView
import Localize_Swift
import Hero

class ViewController: UIViewController, Navigatable, NVActivityIndicatorViewable {
    
    public var viewModel: ViewModel?
    public var navigator: Navigator!
    
    init(viewModel: ViewModel?, navigator: Navigator) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public let isLoading = BehaviorRelay(value: false)
    public let error = PublishSubject<ApiError>()
    public let message = PublishSubject<Message>()
    public let exceptionError = PublishSubject<ExceptionError?>()
    
    public var automaticallyAdjustsLeftBarButtonItem = true
    public var canOpenFlex = true
    
    public let endEditing = PublishSubject<Void>()
    private(set) public lazy var emptyDataView = EmptyDataView.loadFromNib()
    public let emptyDataViewDataSource : EmptyDataViewModel = EmptyDataViewModel()
    
    
    
    var navigationTitle = "" {
        didSet {
            navigationItem.title = navigationTitle
        }
    }
    
    let spaceBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    
    
    public let languageChanged = BehaviorRelay<Void>(value: ())
    public let motionShakeEvent = PublishSubject<Void>()
    
    var topViewController : UIViewController? {
        return UIApplication.topViewController()
    }
    
    lazy var searchBar: SearchBar = {
        let view = SearchBar(height: 36)
        view.textField.placeholder = "Search"
        return view
    }()
    
    lazy var backBarButton: BarButtonItem = {
        let view = BarButtonItem(image: R.image.icon_navigation_back_black(),action: (self,#selector(navigationBack)))
        return view
    }()
    
    lazy var closeBarButton: BarButtonItem = {
        let view = BarButtonItem(image: R.image.icon_navigation_close(),
                                 style: .plain,
                                 target: self,
                                 action: nil)
        return view
    }()
    
    
    private (set) lazy var contentView: View = {
        let view = View()
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
        return view
    }()
    
    private (set) lazy var stackView: StackView = {
        let subviews: [UIView] = []
        let view = StackView(arrangedSubviews: subviews)
        view.spacing = 0
        self.contentView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        stackView.backgroundColor = .clear
        hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.text(), NSAttributedString.Key.font : UIFont.titleFont(18)]
        
        makeUI()
        bindViewModel()
        
        closeBarButton.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            self?.navigator.dismiss(sender: self)
        }).disposed(by: rx.disposeBag)
        
        
        // Observe device orientation change
        NotificationCenter.default
            .rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe { [weak self] (event) in
                self?.orientationChanged()
        }.disposed(by: rx.disposeBag)
        
        // Observe application did become active notification
        NotificationCenter.default
            .rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe { [weak self] (event) in
                self?.didBecomeActive()
        }.disposed(by: rx.disposeBag)
        
        NotificationCenter.default
            .rx.notification(UIAccessibility.reduceMotionStatusDidChangeNotification)
            .subscribe(onNext: { (event) in
                logDebug("Motion Status changed")
            }).disposed(by: rx.disposeBag)
        
        // Observe application did change language notification
        NotificationCenter.default
            .rx.notification(NSNotification.Name(LCLLanguageChangeNotification))
            .subscribe { [weak self] (event) in
                self?.languageChanged.accept(())
        }.disposed(by: rx.disposeBag)
        
        // One finger swipe gesture for opening Flex
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleOneFingerSwipe(swipeRecognizer:)))
        swipeGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeGesture)

        // Two finger swipe gesture for opening Flex and Hero debug
        let twoSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleTwoFingerSwipe(swipeRecognizer:)))
        twoSwipeGesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(twoSwipeGesture)
        
        rx.viewWillDisappear.subscribe({ [weak self] animated in
            self?.view.endEditing(true)
        }).disposed(by: rx.disposeBag)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if automaticallyAdjustsLeftBarButtonItem {
            adjustLeftBarButtonItem()
        }
        updateUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        
        logResourcesCount()
    }
    
    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        logDebug("\(type(of: self)): Received Memory Warning")
    }
    
    func makeUI() {
        
        hero.isEnabled = true
        navigationItem.backBarButtonItem = backBarButton
        
        languageChanged.subscribe(onNext: { [weak self] () in
            //            self?.emptyDataViewModel.title.accept(R.string.localizable.commonNoResults.key.localized())
        }).disposed(by: rx.disposeBag)
        
        motionShakeEvent.subscribe(onNext: { () in
            let theme = themeService.type.toggled()
            themeService.switch(theme)
        }).disposed(by: rx.disposeBag)
        
        themeService.rx
            .bind({ $0.background }, to: view.rx.backgroundColor)
            .bind({ $0.text }, to: [backBarButton.rx.tintColor, closeBarButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
        
        
        emptyDataView.bind(to: emptyDataViewDataSource)
        
        updateUI()
    }
    
    func bindViewModel() {
        
        isLoading.asDriver().drive(onNext: { [weak self] (isLoading) in
            isLoading ? self?.startAnimating() : self?.stopAnimating()
        }).disposed(by: rx.disposeBag)
        
        
        endEditing.subscribe(onNext: {[weak self] () in
            self?.view.endEditing(true)
        }).disposed(by: rx.disposeBag)
        
        
        message.subscribe(onNext: {[weak self] message in
            self?.view.makeToast(message.subTitle,position: .center, title: message.title,style: message.style )
        }).disposed(by: rx.disposeBag)
        
        exceptionError.filterNil().subscribe(onNext: { [weak self] error in
            self?.view.makeToast(error.description)
        }).disposed(by: rx.disposeBag)
        
        
        error.subscribe(onNext: { [weak self] (error) in
            var title = ""
            var description = ""
            switch error {
            case .serverError(let response):
                title = response.message ?? ""
                description = response.detail()
            }
            self?.view.makeToast(description, title: title, image: nil)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func updateUI() {
        
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            motionShakeEvent.onNext(())
        }
    }
    
    func orientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateUI()
        }
    }
    
    func didBecomeActive() {
        self.updateUI()
    }
    
    // MARK: Adjusting Navigation Item
    func adjustLeftBarButtonItem() {
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 { // Pushed
            self.navigationItem.leftBarButtonItem = backBarButton
        } else if self.presentingViewController != nil { // presented
            self.navigationItem.leftBarButtonItem = closeBarButton
        }
    }
    
    @objc func closeAction(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func navigationBack() {
        self.navigator.pop(sender: self)
    }

}

extension ViewController {
    
    var inset: CGFloat {
        return Configs.BaseDimensions.inset
    }
    
    var tabbarHeight : CGFloat {
        if let height =  self.tabBarController?.tabBar.height {
            return height
        } else {
            return 58
        }
    }
    var bottomSafeAreaHeight : CGFloat {
        return Configs.BaseDimensions.bottomSafeArea
    }
    
    
    var navBarWithStatusBarHeight : CGFloat {
        return Configs.BaseDimensions.navBarWithStatusBarHeight
    }
    
    @objc func handleOneFingerSwipe(swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .recognized, canOpenFlex {
            LibsManager.shared.showFlex()
        }
    }
    
    @objc func handleTwoFingerSwipe(swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .recognized {
            LibsManager.shared.showFlex()
            HeroDebugPlugin.isEnabled = !HeroDebugPlugin.isEnabled
        }
    }
}


extension ViewController: DZNEmptyDataSetSource {
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        
        if !emptyDataViewDataSource.enable.value {
            emptyDataView.removeFromSuperview()
            return nil
        }
        emptyDataView.snp.remakeConstraints { (make) in
            make.height.equalTo(scrollView.height)
        }
        
        emptyDataView.needsUpdateConstraints()
        return emptyDataView
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return emptyDataViewDataSource.verticalOffsetY.value
    }
    
    
}

extension ViewController: DZNEmptyDataSetDelegate {
    
    private struct RuntimeKey {
        static var contentInsetTop : String = "RuntimeKey.contentInset.top"
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        
        return !isLoading.value
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}


