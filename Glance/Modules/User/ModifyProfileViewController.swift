//
//  ModifyUserDataViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import CountryPickerView

class ModifyProfileViewController: ViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeProfilePhotoButton: UIButton!
    @IBOutlet weak var userHeadImageView: UIView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var instagramTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var countryView: UIView!
    
    private let countryPickerView = CountryPickerView()

    
    lazy var save : UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: .normal)
        button.titleLabel?.font = UIFont.titleFont(14)
        button.setTitleColor(UIColor(hex:0xFF8159), for: .normal)
        return button
    }()
        
    
    override func makeUI() {
        super.makeUI()
        
        [displayNameTextField,userNameTextField
            ,instagramTextField,websiteTextField]
            .forEach { (view) in
                view?.addLeftTextPadding(10)
        }
        
        countryView.rx.tap()
            .subscribe(onNext: { [weak self]() in
                guard let self = self else { return }
                self.countryPickerView.showCountriesList(from: self)
            }).disposed(by: rx.disposeBag)
        countryPickerView.delegate = self
        navigationTitle = "Edit Profile"
        navigationBar.rightBarButtonItem = save
        stackView.addArrangedSubview(scrollView)
    }
}


extension ModifyProfileViewController : CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        countryLabel.text = country.name
    }
    
    
}
