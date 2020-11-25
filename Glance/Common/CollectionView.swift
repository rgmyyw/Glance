//
//  CollectionView.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class CollectionView: UICollectionView {

    init() {
        super.init(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        makeUI()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }

//    /// 快捷获取itemWidth
//    /// - Parameters:
//    ///   - itemsPerRow: 列
//    ///   - sectionInset: 内边距
//    ///   - itemInset: 元素间距
//    func itemWidth(forItemsPerRow itemsPerRow: Int ,sectionInset : UIEdgeInsets = .zero,  itemInset : CGFloat = 0) -> CGFloat {
//
//        let collectionWidth : CGFloat = frame.size.width
//        if collectionWidth == 0 {
//            return 0
//        }
//
//        var sectionInset : CGFloat = 0
//        var itemInset : CGFloat  = 0
//        let layout = collectionViewLayout as? UICollectionViewFlowLayout
//
//        if sectionInset == .zero , let layout = layout {
//            sectionInset = layout.sectionInset.left + layout.sectionInset.right
//        }
//        if itemInset == 0  ,let layout = layout {
//            itemInset = (itemsPerRow.cgFloat - 1.0) * layout.minimumInteritemSpacing
//        }
//
//        return (collectionWidth - sectionInset - itemInset) / itemsPerRow.cgFloat
//    }

    func setItemSize(_ size: CGSize) {
        if size.width == 0 || size.height == 0 {
            return
        }
        let layout = (self.collectionViewLayout as? UICollectionViewFlowLayout)!
        layout.itemSize = size
    }
}

extension UICollectionView {

    /// 快捷获取itemWidth
    /// - Parameters:
    ///   - itemsPerRow: 列
    ///   - sectionInset: 内边距
    ///   - itemInset: 元素间距
    func itemWidth(forItemsPerRow itemsPerRow: Int, sectionInset: UIEdgeInsets = .zero, itemInset: CGFloat = 0) -> CGFloat {

        let collectionWidth: CGFloat = frame.size.width
        if collectionWidth == 0 { return 0 }

        let sectionInset: CGFloat = sectionInset.left + sectionInset.right
        let itemInset: CGFloat  = CGFloat(itemsPerRow  - 1) * itemInset

        return (collectionWidth - sectionInset - itemInset) / itemsPerRow.cgFloat
    }

}
