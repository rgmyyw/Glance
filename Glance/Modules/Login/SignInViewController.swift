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


class SignInViewController: UIViewController {
        
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var instagramImageView: UIImageView!
        
    
    let type = PublishSubject<SignInType>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        instagramImageView.rx.tap().map { SignInType.instagram }
            .bind(to: type).disposed(by: rx.disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self]() in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
}
