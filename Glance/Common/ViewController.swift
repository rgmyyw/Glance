//
//  ViewController.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DZNEmptyDataSet
import NVActivityIndicatorView
import Localize_Swift
import Hero
import Toast_Swift



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
    
    
    public var messageToastPosition: ToastPosition = .bottom
    public var exceptionToastPosition: ToastPosition = .bottom
    
    private(set) public lazy var errorToastStyle : ToastStyle =  ToastManager.shared.style
    private(set) public lazy var messageToastStyle : ToastStyle =  ToastManager.shared.style
    
    private(set) public lazy var backButton : UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_navigation_back_black(), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    private(set) public lazy var closeButton : UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_navigation_close(), for: .normal)
        button.sizeToFit()
        return button
    }()

    
    
    var navigationTitle = "" {
        didSet {
            navigationBar.title = navigationTitle
        }
    }
        
    
    public let languageChanged = BehaviorRelay<Void>(value: ())
    public let motionShakeEvent = PublishSubject<Void>()
    
    private(set) lazy var navigationBar : NavigationBar = NavigationBar(height: 44)
    
    private(set) lazy var contentView: View = {
        let view = View()
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
        navigationBar.bottomLineColor = UIColor(hex: 0xEEEEEE)
        navigationBar.bottomLineView.isHidden = true
        let containerView = StackView(arrangedSubviews: [navigationBar,stackView])
        containerView.spacing = 0
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return view
    }()

    private (set) lazy var stackView: StackView = {
        let subviews: [UIView] = []
        let view = StackView(arrangedSubviews: subviews)
        view.spacing = 0
        return view
    }()

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
                
        // Do any additional setup after loading the view.
        contentView.backgroundColor = .clear
                
        makeUI()
        bindViewModel()
        navigationController?.setNavigationBarHidden(true, animated:false)
        
        
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
                
        backButton.addTarget(self, action: #selector(navigationBack), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
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

        languageChanged.subscribe(onNext: {  () in
            
        }).disposed(by: rx.disposeBag)
        
        motionShakeEvent.subscribe(onNext: { () in
            let theme = themeService.type.toggled()
            themeService.switch(theme)
        }).disposed(by: rx.disposeBag)
        
        themeService.rx
            .bind({ $0.background }, to: view.rx.backgroundColor)
//            .bind({ $0.text }, to: [backBarButton.rx.tintColor, closeBarButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
        
        
        emptyDataView.bind(to: emptyDataViewDataSource)
        
        
        updateUI()
    }
    
    func bindViewModel() {
        
        viewModel?.endEditing.bind(to: endEditing).disposed(by: rx.disposeBag)
        viewModel?.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel?.message.bind(to: message).disposed(by: rx.disposeBag)
        viewModel?.exceptionError.bind(to: exceptionError).disposed(by: rx.disposeBag)
        viewModel?.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        
        
        isLoading.asDriver().drive(onNext: { [weak self] (isLoading) in
            isLoading ? self?.startAnimating() : self?.stopAnimating()
        }).disposed(by: rx.disposeBag)
        
                
        Observable.merge(rx.viewWillDisappear.mapToVoid(),endEditing)
            .subscribe(onNext: {[weak self] () in
            self?.view.endEditing(true)
        }).disposed(by: rx.disposeBag)
        
        
        message.subscribe(onNext: {[weak self] message in
            let view = self?.topViewController()?.view
            let position = self?.messageToastPosition ?? .bottom
            view?.makeToast(message.subTitle,position: position, title: message.title,style: message.style )
        }).disposed(by: rx.disposeBag)
        
        exceptionError.filterNil().subscribe(onNext: { [weak self] error in
            let view = self?.topViewController()?.view
            let position = self?.exceptionToastPosition ?? .bottom
            view?.makeToast(error.description,position: position)
        }).disposed(by: rx.disposeBag)
        
        
        error.subscribe(onNext: { [weak self] (error) in
            var title = ""
            var description = ""
            switch error {
            case .serverError(let response):
                title = response.message ?? ""
                description = response.detail()
            }
            self?.stopAnimating()
            let view = self?.topViewController()?.view
            let position = self?.exceptionToastPosition ?? .bottom
            view?.makeToast(description, position: position, title: title)
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
    
    @objc func closeAction() {
        self.navigator.dismiss(sender: self, animated: true)
    }
    
    @objc func navigationBack() {
        self.navigator.pop(sender: self)
    }
    
    // MARK: Adjusting Navigation Item
    func adjustLeftBarButtonItem() {
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 { // Pushed
            self.navigationBar.leftBarButtonItems.insert(backButton, at: 0)
        } else if self.presentingViewController != nil { // presented
            self.navigationBar.leftBarButtonItems.insert(closeButton, at: 0)
        }
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
        return emptyDataView
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0
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


