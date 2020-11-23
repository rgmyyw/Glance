//
//  InstagramSignInPopView.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum SignInType {
    case instagram
}

class SignInViewController: ViewController {
    
    let type = PublishSubject<SignInType>()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var instagramButton: UIButton!
    
    override func makeUI() {
        super.makeUI()
        stackView.addArrangedSubview(containerView)
        instagramButton.addGradient(colors: [UIColor(hex: 0xFF8D5F),UIColor(hex: 0xFFB465)], start: .zero, end: CGPoint(x: 1, y: 1))
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SignInViewModel else { return }
        
        let input = SignInViewModel.Input(instagram: instagramButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.instagramOAuth.drive(onNext: { [weak self]() in
            OAuthManager.shared.instagramOAuth(presenting: self)
        }).disposed(by: rx.disposeBag)
        
        output.tabbar.delay(RxTimeInterval.milliseconds(500)).drive(onNext: { () in
            guard let window = Application.shared.window else { return }
            Application.shared.showTabbar(provider: viewModel.provider, window: window)
        }).disposed(by: rx.disposeBag)
        
        output.interest.delay(RxTimeInterval.milliseconds(500)).drive(onNext: { () in
            guard let window = Application.shared.window else { return }
            Application.shared.showInterest(provider: viewModel.provider, window: window)
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        instagramButton.rx.tap.map { SignInType.instagram }
            .bind(to: type).disposed(by: rx.disposeBag)
        
    }
}
