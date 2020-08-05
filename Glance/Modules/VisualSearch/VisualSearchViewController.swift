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
    
    let cropView : VisualSearchCropView = VisualSearchCropView()
    let panel = FloatingPanelController()
    let bottomView : VisualSearchBottomView = VisualSearchBottomView.loadFromNib(height : 100)
    
    override func makeUI() {
        super.makeUI()
        
        
        
        contentView.removeFromSuperview()
        view.addSubview(cropView)
        cropView.frame = CGRect(x: 0, y: 0, w: view.bounds.width, h: UIScreen.height * 0.5)
        cropView.backgroundColor = UIColor.black
        view.backgroundColor = cropView.backgroundColor
        
        panel.surfaceView.backgroundColor = UIColor(displayP3Red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
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
        
        let input = VisualSearchViewModel.Input(currentRect: cropView.current.asObservable())
        let output = viewModel.transform(input: input)
        
        let result = VisualSearchResultViewModel(provider: viewModel.provider)

        result.bottomViewHidden.subscribe(onNext: { [weak self] (hidden) in
            UIView.animate(withDuration: 0.25) { self?.bottomView.alpha = (!hidden).int.cgFloat }
        }).disposed(by: rx.disposeBag)
        let vc = VisualSearchResultViewController(viewModel: result, navigator: navigator)
        
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.collectionView)
        
        output.currentRect.drive(result.currentRect).disposed(by: rx.disposeBag)
        output.imageURI.drive(result.imageURI).disposed(by: rx.disposeBag)
        
        viewModel.image.bind(to: cropView.rx.image).disposed(by: rx.disposeBag)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        
    }
    
    
    
}

extension VisualSearchViewController  : FloatingPanelControllerDelegate {
    
    // MARK: FloatingPanelControllerDelegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        let layout = FloatingPanelStocksLayout()
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
    
    var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.half,.full]
    }
    
    var topInteractionBuffer: CGFloat { return 0.0 }
    var bottomInteractionBuffer: CGFloat { return 0.0 }
    
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 20
        case .half: return (UIScreen.height * 0.5) - 34 - 20
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
