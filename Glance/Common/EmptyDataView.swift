//
//  EmptyDataView.swift
//  
//
//  Created by 杨海 on 2020/4/4.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EmptyDataViewModel {
    
    let title = BehaviorRelay<String?>(value: nil)
    let subTitle = BehaviorRelay<String?>(value: nil)
    let image = BehaviorRelay<UIImage?>(value: nil)
    let buttonTitle = BehaviorRelay<String?>(value: nil)
    let backgroundColor = BehaviorRelay<UIColor>(value: .clear)
    let verticalOffsetY = BehaviorRelay<CGFloat>(value: 0 )
    let contentInsetTop = BehaviorRelay<CGFloat>(value: 0)
    
    
    
    
    let tap = PublishSubject<Void>()
    let enable =  BehaviorRelay<Bool>(value: true)
    
    init(title : String? = "Empty",
         image : UIImage? = R.image.icon_empty_default(),
         subTitle : String? = "Hurry up and collect one",
         buttonTitle : String? = nil) {
        self.title.accept(title)
        self.subTitle.accept(subTitle)
        self.image.accept(image)
        self.buttonTitle.accept(buttonTitle)
    }
}

class EmptyDataView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var buttonBgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    func bind(to viewModel : EmptyDataViewModel) {
        
        viewModel.title.filterNil().bind(to: titleLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.subTitle.filterNil().bind(to: subTitleLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.image.filterNil().bind(to: imageView.rx.image).disposed(by: rx.disposeBag)
        viewModel.buttonTitle.filterNil().bind(to: button.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        
        viewModel.title.map { $0 == nil }.bind(to: titleLabel.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.buttonTitle.map { $0 == nil }.bind(to: buttonBgView.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.image.map { $0 == nil }.bind(to: imageView.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.subTitle.map { $0 == nil }.bind(to: subTitleLabel.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.backgroundColor.bind(to: rx.backgroundColor).disposed(by: rx.disposeBag)
        
        button.rx.tap.asObservable().bind(to: viewModel.tap).disposed(by: rx.disposeBag)
            
    }

    
}
