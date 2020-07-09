//
//  UIImageView.swift
//  
//
//  Created by yanghai on 2019/12/16.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    
    ///  kf 设置图像函数
    ///
    /// - parameter urlStr:           urlString
    /// - parameter placeholderImage: 占位图像
    /// - parameter avatar:         是否头像（设置圆角）
    public func setImage(url: URL?, placeholderImage: UIImage?, avatar: Bool = false) {
        
        guard let url = url else {
            image = placeholderImage
            return
        }
         
        let resource = ImageResource(downloadURL: url)
        kf.setImage(with: resource, placeholder: placeholderImage, options: [], progressBlock: nil) { [weak self](result) in
            if avatar {
//                self?.image =  try? result.get().image.withRoundedCorners(radius: self.size.height ?? .zero)
            }
        }
    }
    
    ///  kf 设置图像函数
    ///
    /// - parameter urlStr:           urlString
    /// - parameter placeholderImage: 占位图像
    /// - parameter avatar:         是否头像（设置圆角）
    public func setImage(url: String?, placeholderImage: UIImage?, avatar: Bool = false) {
        setImage(url: URL(string: url ?? ""), placeholderImage: placeholderImage ,avatar : avatar)
    }
    

}
