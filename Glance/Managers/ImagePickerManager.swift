//
//  ImagePickerManager.swift
//  Glance
//
//  Created by yanghai on 2020/7/28.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ZLPhotoBrowser

class ImagePickerManager {
    
    public static let shared = ImagePickerManager()
    private init() {}
    
    func showPhotoLibrary(sender : UIViewController? = nil,
                          animate : Bool = true ,
                          configuration : ((ZLPhotoConfiguration) -> ())? = nil,
                          selectImageBlock : (([UIImage]?, [PHAsset] ,Bool)-> Void)? = nil ) {
        photoActionSheet(sender: sender, configuration: configuration, selectImageBlock: selectImageBlock).showPhotoLibrary()
    }
    
    func showPreview(sender : UIViewController? = nil,
                     animate : Bool = true ,
                     configuration : ((ZLPhotoConfiguration) -> ())? = nil,
                     selectImageBlock : (([UIImage]?, [PHAsset] ,Bool)-> Void)? = nil ) {
        photoActionSheet(sender: sender, configuration: configuration, selectImageBlock: selectImageBlock).showPreview(animate: animate)
    }
}

extension ImagePickerManager {
    
    func photoActionSheet(sender : UIViewController?,
                          configuration : ((ZLPhotoConfiguration) -> ())? = nil,
                          selectImageBlock : (([UIImage]?, [PHAsset] ,Bool)-> Void)? = nil ) -> ZLPhotoActionSheet {
        
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
        ac.configuration.sortAscending = false
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
        // ac.configuration.editAfterSelectThumbnailImage = true
        // 是否保存编辑后的图片
        //ac.configuration.saveNewImageAfterEdit = false
        // 设置编辑比例
        ac.configuration.clipRatios = [GetClipRatio(1, 1)]
        
        // 是否在已选择照片上显示遮罩层
        ac.configuration.showSelectedMask = false
        ac.configuration.showSelectedIndex = true
        
        
        let theme : UIColor = .black
        let text : UIColor = .white
        
        // preview
        ac.configuration.previewTextColor = text
        ac.configuration.maxPreviewCount = 20
        
        // 导航样式
        ac.configuration.navBarColor = theme
        ac.configuration.navTitleColor = ac.configuration.previewTextColor
        ac.configuration.statusBarStyle = .default
        ac.configuration.allowDragSelect = true
        
        // 工具栏样式
        ac.configuration.bottomBtnsDisableBgColor = UIColor.lightGray
        ac.configuration.bottomBtnsNormalTitleColor = text
        ac.configuration.bottomViewBgColor = theme
        ac.configuration.bottomBtnsNormalBgColor = .clear
        ac.configuration.bottomBtnsDisableBgColor = .clear
        
        ac.configuration.shouldAnialysisAsset = true
        ac.configuration.languageType = .system
        
        // 回调给外界配置，外界配置会覆盖当前配置
        configuration?(ac.configuration)
        
        // MARK: required
        let count = 1
        if  count > 1 {
            //ac.arrSelectedAssets = NSMutableArray(array: self.lastSelectAssets)
        } else {
            ac.arrSelectedAssets = nil
        }
        
        ac.selectImageBlock = selectImageBlock
        
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexes) in
            debugPrint("图片解析出错索引为: \(errorIndexes), 对应assets为: \(errorAssets)")
        }
        
        ac.cancleBlock = {
            debugPrint("取消选择图片")
        }
        
        ac.sender = sender
        return ac
    }
    
}
