//
//  PrivacyViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class PrivacyViewController: ViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var blockedListCell: UIView!
    
    override func makeUI() {
        super.makeUI()
        navigationTitle = "Privacy"
        stackView.addArrangedSubview(scrollView)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? PrivacyViewModel else { return }
        
        blockedListCell.rx.tap().subscribe(onNext: { [weak self] () in
            let viewModel = UsersViewModel(provider: viewModel.provider, type: .blocked)
            self?.navigator.show(segue: .users(viewModel: viewModel), sender: self)
        }).disposed(by: rx.disposeBag)
        
    }

    
    
}
