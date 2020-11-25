//
//  VisualSearchViewController.swift
//  Glance
//
//  Created by yanghai on 2020/7/28.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import FloatingPanel

class VisualSearchViewController: ViewController {

    fileprivate let cropView: VisualSearchCropView = VisualSearchCropView()
    fileprivate let panel = FloatingPanelController()
    fileprivate let bottomView: VisualSearchBottomView = VisualSearchBottomView.loadFromNib(height: 100)
    fileprivate lazy var postProduct: PostProductViewController = {
        let viewModel = PostProductViewModel(provider: self.viewModel!.provider, image: nil, taggedItems: [])
        let controller  = PostProductViewController(viewModel: viewModel, navigator: navigator)
        return controller
    }()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func makeUI() {
        super.makeUI()

        contentView.removeFromSuperview()
        view.addSubview(cropView)
        cropView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width )
        cropView.backgroundColor = UIColor.black
        view.backgroundColor = cropView.backgroundColor?.withAlphaComponent(0.5)

        panel.surfaceView.backgroundColor = UIColor.background()
        panel.surfaceView.setValue(10, forKey: "cornerRadius")
        panel.surfaceView.setValue(1.0 / traitCollection.displayScale, forKey: "borderWidth")
        panel.surfaceView.setValue(UIColor.black.withAlphaComponent(0.2), forKey: "borderColor")
        panel.delegate = self
        panel.surfaceView.shadowHidden = false
        panel.surfaceView.setNeedsLayout()
        panel.surfaceView.grabberHandle.isHidden = true

        bottomView.alpha = 0
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.left.right.equalTo(view)
            make.height.equalTo(100)
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(bottomView)
    }

    override func bindViewModel() {
        super.bindViewModel()

        guard let viewModel = viewModel as? VisualSearchViewModel else { return }

        let input = VisualSearchViewModel.Input(currentBox: cropView.current.asObservable(),
                                                commit: bottomView.button.rx.tap.asObservable())
        let output = viewModel.transform(input: input)

        // 提前绑定, 重复绑定会出发多次
        (self.postProduct.viewModel as? PostProductViewModel)?.reselection
            .bind(to: viewModel.reselection).disposed(by: rx.disposeBag)

        output.post.subscribe(onNext: { [weak self](image, items) in
            guard let self = self else { return }
            let postProductViewModel = self.postProduct.viewModel as? PostProductViewModel
            postProductViewModel?.image.accept(image)
            postProductViewModel?.element.accept(items)
            self.navigationController?.pushViewController(self.postProduct)
        }).disposed(by: rx.disposeBag)

        output.dots.drive(cropView.rx.dots).disposed(by: rx.disposeBag)
        output.selection.drive(cropView.rx.selection).disposed(by: rx.disposeBag)

        let result = VisualSearchResultViewModel(provider: viewModel.provider, image: viewModel.image.value, mode: viewModel.mode.value)
        result.dots.bind(to: viewModel.dots).disposed(by: rx.disposeBag)
        result.bottomViewHidden.subscribe(onNext: { [weak self] (hidden) in
            self?.bottomView.button.isUserInteractionEnabled = !hidden
            UIView.animate(withDuration: 0.25) {
                self?.bottomView.alpha = (!hidden).int.cgFloat
            }
        }).disposed(by: rx.disposeBag)

        let vc = VisualSearchResultViewController(viewModel: result, navigator: navigator)
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.collectionView)

        output.current.drive(result.current).disposed(by: rx.disposeBag)
        output.imageURI.drive(result.imageURI).disposed(by: rx.disposeBag)
        viewModel.image.bind(to: cropView.rx.image).disposed(by: rx.disposeBag)
    }

}

extension VisualSearchViewController: FloatingPanelControllerDelegate {

    // MARK: FloatingPanelControllerDelegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        let layout = FloatingPanelStocksLayout()
        layout.halfHeight = view.height - cropView.height
        return layout
    }

    func floatingPanel(_ vc: FloatingPanelController, behaviorFor newCollection: UITraitCollection) -> FloatingPanelBehavior? {
        return FloatingPanelStocksBehavior()
    }

    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        //        if vc.position == .full {
        //            UIView.animate(withDuration: 0.25) {
        //                self.view.backgroundColor = UIColor.black
        //            }
        //        } else if vc.position == .half {
        //            UIView.animate(withDuration: 0.25) {
        //                self.view.backgroundColor = UIColor.white
        //            }
        //        }
    }
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        //        if targetPosition == .full {
        //            UIView.animate(withDuration: 0.25) {
        //                self.view.backgroundColor = .black
        //            }
        //        } else if targetPosition == .half {
        //            UIView.animate(withDuration: 0.25) {
        //                self.view.backgroundColor = .black
        //            }
        //
        //        }
    }

}

// MARK: My custom layout
class FloatingPanelStocksLayout: FloatingPanelLayout {

    var halfHeight: CGFloat = UIScreen.width

    var initialPosition: FloatingPanelPosition {
        return .half
    }

    var supportedPositions: Set<FloatingPanelPosition> {
        return [.half, .full]
    }

    var topInteractionBuffer: CGFloat { return 0.0 }
    var bottomInteractionBuffer: CGFloat { return 0.0 }

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 0
        case .half:
            var  bottomSafeArea: CGFloat = 0
            if #available(iOS 11, *) {
                bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            }
            return halfHeight - bottomSafeArea //(UIScreen.height * 0.5) - 34 - 20
        case .tip: return 85.0 + 44.0 // Visible + ToolView

        default: return nil
        }
    }

    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}

// MARK: My custom behavior
class FloatingPanelStocksBehavior: FloatingPanelBehavior {

    var velocityThreshold: CGFloat {
        return 15.0
    }

    func interactionAnimator(_ fpc: FloatingPanelController, to targetPosition: FloatingPanelPosition, with velocity: CGVector) -> UIViewPropertyAnimator {
        let timing = timeingCurve(to: targetPosition, with: velocity)
        return UIViewPropertyAnimator(duration: 0, timingParameters: timing)
    }

    private func timeingCurve(to: FloatingPanelPosition, with velocity: CGVector) -> UITimingCurveProvider {
        let damping = self.damping(with: velocity)
        return UISpringTimingParameters(dampingRatio: damping,
                                        frequencyResponse: 0.4,
                                        initialVelocity: velocity)
    }

    private func damping(with velocity: CGVector) -> CGFloat {
        switch velocity.dy {
        case ...(-velocityThreshold):
            return 0.7
        case velocityThreshold...:
            return 0.7
        default:
            return 1.0
        }
    }
}
