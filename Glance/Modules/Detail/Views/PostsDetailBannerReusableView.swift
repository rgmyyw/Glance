//
//  PostsDetailBannerReusableView.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import JXBanner
import JXPageControl
import RxSwift
import RxCocoa

class PostsDetailBannerReusableView: CollectionReusableView {

    @IBOutlet weak var banner: JXBanner!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var visearchButton: UIButton!

    let items = BehaviorRelay<[String]>(value: [])

    override func makeUI() {
        super.makeUI()

        banner.placeholderImgView.image = UIImage(named: "banner_placeholder")
        banner.delegate = self
        banner.dataSource = self
    }

    override func bind<T>(to viewModel: T) where T: PostsDetailSectionCellViewModel {
        super.bind(to: viewModel)

        viewModel.postImageURL.bind(to: imageView.rx.imageURL).disposed(by: cellDisposeBag)
        visearchButton.rx.tap.map { self.imageView.image}.bind(to: viewModel.viSearch).disposed(by: rx.disposeBag)
    }

}

// MARK: - JXBannerDataSource
extension PostsDetailBannerReusableView: JXBannerDataSource {

    func jxBanner(_ banner: JXBannerType)
        -> (JXBannerCellRegister) {
            return JXBannerCellRegister(type: PostsDetailBannerCell.self,
                                        reuseIdentifier: "PostsDetailBannerCell",
                                        nib: PostsDetailBannerCell.nib)
    }

    func jxBanner(numberOfItems banner: JXBannerType)
        -> Int { return items.value.count }

    func jxBanner(_ banner: JXBannerType,
                  cellForItemAt index: Int,
                  cell: UICollectionViewCell)
        -> UICollectionViewCell {
            guard let tempCell = cell as? PostsDetailBannerCell else { fatalError() }
            tempCell.contentMode = .scaleToFill
            tempCell.imageView.image = UIImage(named: items.value[index])

            return tempCell
    }

    func jxBanner(_ banner: JXBannerType, layoutParams: JXBannerLayoutParams) -> JXBannerLayoutParams {

        layoutParams.itemSize = CGSize(width: UIScreen.width, height: 350)
        layoutParams.itemSpacing = 0
        //        layoutParams.maximumAngle = 0
        //        layoutParams.minimumAlpha = 1
        //        layoutParams.rateHorisonMargin = 1
        //        layoutParams.rateOfChange = 0
        //        layoutParams.layoutType = nil
        return layoutParams
    }

    func jxBanner(_ banner: JXBannerType, params: JXBannerParams) -> JXBannerParams {
        params.timeInterval = 1.5
        params.isAutoPlay = true
        params.cycleWay = .forward
        return params
    }

    func jxBanner(pageControl banner: JXBannerType, numberOfPages: Int, coverView: UIView, builder: JXBannerPageControlBuilder) -> JXBannerPageControlBuilder {
        let pageControl = JXPageControlScale()
        pageControl.contentMode = .bottom
        pageControl.activeSize = CGSize(width: 12, height: 5)
        pageControl.inactiveSize = CGSize(width: 5, height: 5)
        pageControl.activeColor = UIColor.primary()
        pageControl.inactiveColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.columnSpacing = 0
        pageControl.isAnimation = true
        builder.pageControl = pageControl
        builder.layout = {
            pageControl.snp.makeConstraints { (maker) in
                maker.left.right.equalTo(coverView)
                maker.bottom.equalTo(coverView.snp.bottom).offset(-20)
                maker.height.equalTo(28)
            }
        }
        return builder

    }

}

// MARK: - JXBannerDelegate
extension PostsDetailBannerReusableView: JXBannerDelegate {

    public func jxBanner(_ banner: JXBannerType,
                         didSelectItemAt index: Int) {
        //print(index)
    }

    func jxBanner(_ banner: JXBannerType, center index: Int) {
        //print(index)
    }

}
