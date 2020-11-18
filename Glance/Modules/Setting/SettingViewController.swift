//
//  SettingViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/7.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class SettingViewController: ViewController {
    
    @IBOutlet var items: [UIView]!
    @IBOutlet weak var navigationHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func makeUI() {
        super.makeUI()
        
        stackView.addArrangedSubview(scrollView)
        navigationBar.isHidden = true
        navigationHeight.constant = UIApplication.shared.statusBarFrame.height + 44
    }
 
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? SettingViewModel else { return }
        items.tapGesture().map { SettingItem(rawValue: $0)}
            .filterNil().bind(to: viewModel.selectedItem).disposed(by: rx.disposeBag)
        viewModel.selectedItem
            .subscribe(onNext: { [weak self](_) in
                self?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
