//
//  SearchBar.swift
//  ibex
//
//  Created by yanghai on 2020/4/10.
//  Copyright © 2020 gxd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class SearchBar: View, UITextFieldDelegate {

    lazy var bgView: View = {
        let view = View()
        view.backgroundColor = UIColor(hex: 0xF1F1F1)
        view.addSubview(textField)
        view.addSubview(searchImageView)
        return view
    }()

    private lazy var searchImageView: ImageView = {
        let view = ImageView(frame: .zero)
        view.image = R.image.icon_search()
        view.contentMode = .scaleAspectFit
        view.sizeToFit()
        view.snp.makeConstraints({ (make) in
            make.size.equalTo(view.image?.size ?? .zero)
        })
        return view
    }()

    lazy var textField: UITextField = {
        let view = UITextField()
        view.text = ""
        view.textColor = UIColor.text()
        view.placeholder = "Search"
        view.isUserInteractionEnabled = false
        view.isSecureTextEntry = false
        view.font = UIFont.titleBoldFont(14)
        view.textAlignment = .left
        view.keyboardType = .webSearch
        view.autocapitalizationType = .none
        view.delegate = self
        return view
    }()

    let textFieldReturn = PublishSubject<Void>()

    override func makeUI() {
        super.makeUI()
        addSubview(bgView)
        backgroundColor = .clear

        bgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(snp.top)//.offset(4)
            make.bottom.equalTo(snp.bottom)//.offset(-4)
        }

        searchImageView.snp.makeConstraints { (make) in
            make.left.equalTo(inset)
            make.centerY.equalTo(bgView.snp.centerY)
        }

        textField.snp.makeConstraints { (make) in
            make.left.equalTo(searchImageView.snp.right).offset(4)
            make.right.equalTo(bgView.snp.right).offset(-inset)
            make.centerY.equalTo(searchImageView).offset(2)
        }

    }

    override var intrinsicContentSize: CGSize {

        return UIView.layoutFittingExpandedSize
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        bgView.cornerRadius = bgView.height * 0.5

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldReturn.onNext(())
        return true
    }
}
