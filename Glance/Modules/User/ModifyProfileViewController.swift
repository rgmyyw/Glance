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
    @IBOutlet weak var userHeadImageView: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var instagramTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var displayNameCharactersCountLabel: UILabel!
    @IBOutlet weak var userNameCharactersCountLabel: UILabel!

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
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? ModifyProfileViewModel else { return }
        let input = ModifyProfileViewModel.Input(save: save.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.userHeadImageURL.drive(userHeadImageView.rx.imageURL).disposed(by: rx.disposeBag)
        output.countryName.drive(countryLabel.rx.text).disposed(by: rx.disposeBag)
        (displayNameTextField.rx.textInput <-> viewModel.displayName).disposed(by: rx.disposeBag)
        (userNameTextField.rx.textInput <-> viewModel.userName).disposed(by: rx.disposeBag)
        (instagramTextField.rx.textInput <-> viewModel.instagram).disposed(by: rx.disposeBag)
        (websiteTextField.rx.textInput <-> viewModel.website).disposed(by: rx.disposeBag)
        (bioTextView.rx.textInput <-> viewModel.bio).disposed(by: rx.disposeBag)
        userNameTextField.rx.text.map { $0?.count ?? 0}.map { "\($0)/20"}.bind(to: userNameCharactersCountLabel.rx.text).disposed(by: rx.disposeBag)
        displayNameTextField.rx.text.map { $0?.count ?? 0}.map { "\($0)/20"}.bind(to: displayNameCharactersCountLabel.rx.text).disposed(by: rx.disposeBag)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        viewModel.endEditing.bind(to: endEditing).disposed(by: rx.disposeBag)
    }
    
    
}


extension ModifyProfileViewController : CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        (viewModel as? ModifyProfileViewModel)?.country.accept(country)
        countryLabel.text = country.name
    }
    
}
