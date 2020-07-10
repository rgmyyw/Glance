//
//  ModifyUserDataViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import CountryPickerView
import ZLPhotoBrowser

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
    private var lastSelectAssets: [PHAsset] = []
    private var lastSelectImages: [UIImage] = []
    private var images: [UIImage] = []
    private var isOriginal: Bool = false
    
    
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
        
        changeProfilePhotoButton.rx.tap
            .subscribe(onNext: { [weak self]() in
                self?.getPhotoActionSheet().showPreview(animate: true)
        }).disposed(by: rx.disposeBag)
        
        userNameTextField.limitCharacter(number: 20)
        displayNameTextField.limitCharacter(number: 20)

    }
    
    
}


extension ModifyProfileViewController : CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        (viewModel as? ModifyProfileViewModel)?.country.accept(country)
        countryLabel.text = country.name
    }
    
}

extension ModifyProfileViewController {
    
    func getPhotoActionSheet() -> ZLPhotoActionSheet {
        
        let ac = ZLPhotoActionSheet()
        // MARK: 参数配置 optional
        
        // 以下参数为自定义参数，均可不设置，有默认值
        ac.configuration.sortAscending = true
        ac.configuration.allowSelectImage = true
        ac.configuration.allowSelectGif = false
        ac.configuration.allowSelectVideo = false
        ac.configuration.allowSelectLivePhoto = false
        ac.configuration.allowForceTouch = true
        ac.configuration.allowEditImage = true
        ac.configuration.allowEditVideo = false
        ac.configuration.allowSlideSelect = false
        ac.configuration.mutuallyExclusiveSelectInMix = false
        ac.configuration.allowDragSelect = true
        ac.configuration.allowSelectOriginal = false
        
        
        
        // 设置相册内部显示拍照按钮
        ac.configuration.allowTakePhotoInLibrary = true
        // 设置在内部拍照按钮上实时显示相机俘获画面
        ac.configuration.showCaptureImageOnTakePhotoBtn = true
        // 最大预览数
        ac.configuration.maxPreviewCount = 20
        //最大选择数
        ac.configuration.maxSelectCount = 1
        // 允许选择视频的最大时长
        ac.configuration.maxVideoDuration = 120
        // cell 弧度
        ac.configuration.cellCornerRadio = 0
        // 单选模式是否显示选择按钮
        ac.configuration.showSelectBtn = false
        // 是否在选择图片后直接进入编辑界面
        ac.configuration.editAfterSelectThumbnailImage = true
        // 是否保存编辑后的图片
        //ac.configuration.saveNewImageAfterEdit = false
        // 设置编辑比例
        ac.configuration.clipRatios = [GetClipRatio(1, 1)]
        
        // 是否在已选择照片上显示遮罩层
        ac.configuration.showSelectedMask = false
        ac.configuration.showSelectedIndex = true
        
        
        // preview
        ac.configuration.previewTextColor = UIColor(hex: 0x333333)
        ac.configuration.maxPreviewCount = 20
        
        // 导航样式
        ac.configuration.navBarColor = .white
        ac.configuration.navTitleColor = ac.configuration.previewTextColor
        ac.configuration.statusBarStyle = .default
        ac.configuration.allowDragSelect = true
        
        
        // 工具栏样式
        ac.configuration.bottomBtnsDisableBgColor = UIColor.lightGray
        ac.configuration.bottomBtnsNormalTitleColor = UIColor(hex: 0xFF8159)
        ac.configuration.bottomViewBgColor = UIColor.white
        ac.configuration.bottomBtnsNormalBgColor = .clear
        ac.configuration.bottomBtnsDisableBgColor = .clear
        
        ac.configuration.shouldAnialysisAsset = true
        ac.configuration.languageType = .system
        
        // MARK: required
        let count = 1
        if  count > 1 {
            //ac.arrSelectedAssets = NSMutableArray(array: self.lastSelectAssets)
        } else {
            ac.arrSelectedAssets = nil
        }
        
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.images = images ?? []
            self?.isOriginal = isOriginal
            self?.lastSelectAssets = assets
            self?.lastSelectImages = images ?? []
            self?.userHeadImageView.image = images?.first
            (self?.viewModel as? ModifyProfileViewModel)?.selectedImage.accept(images?.first)
            debugPrint("images: \(String(describing: images))")
        }
        
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexes) in
            debugPrint("图片解析出错索引为: \(errorIndexes), 对应assets为: \(errorAssets)")
        }
        
        ac.cancleBlock = {
            debugPrint("取消选择图片")
        }
        
        ac.sender = self
        return ac
    }
    
}
