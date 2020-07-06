//
//  Kingfisher+Rx.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

extension Reactive where Base: UIImageView {

    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }

    public func imageURL(withPlaceholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<URL?> {
        return Binder(self.base, binding: { (imageView, url) in
            imageView.kf.setImage(with: url,
                                  placeholder: placeholderImage,
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: { (result) in })
        })
    }
}

extension Reactive where Base: UIButton {

    public var imageURL: Binder<URL?> {
        return imageURL(for: .normal, placeholder: nil, options: [])
    }

    public func imageURL(for controlState: UIControl.State = [],placeholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<URL?> {
        return Binder(self.base, binding: { (button, url) in
            if let url = url {
                button.kf.setImage(with: ImageResource(downloadURL: url), for: controlState, placeholder: placeholderImage, options: options, progressBlock: nil, completionHandler: { (result) in })
            }
        })
    }

}



extension ImageCache: ReactiveCompatible {}

extension Reactive where Base: ImageCache {

    func retrieveCacheSize() -> Observable<Int> {
        return Single.create { single in
            self.base.calculateDiskStorageSize { (result) in
                do {
                    single(.success(Int(try result.get())))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create { }
        }.asObservable()
    }

    public func clearCache() -> Observable<Void> {
        return Single.create { single in
            self.base.clearMemoryCache()
            self.base.clearDiskCache(completion: {
                single(.success(()))
            })
            return Disposables.create { }
        }.asObservable()
    }
}


