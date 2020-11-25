//
//  PanelManager.swift
//  Glance
//
//  Created by yanghai on 2020/9/21.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import FloatingPanel

struct PanelDefaultModalStyle {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 1
    var borderColor: UIColor = UIColor.black.withAlphaComponent(0.2)
    var shadowHidden: Bool = false
    var isRemovalInteractionEnabled: Bool = true

    static var `default` : PanelDefaultModalStyle {
        return PanelDefaultModalStyle()
    }
}

extension FloatingPanelControllerDelegate where Self: UIViewController {

    func floatingPanel(_ vc: FloatingPanelController, contentOffsetForPinning trackedScrollView: UIScrollView) -> CGPoint {
        return CGPoint(x: 0.0, y: 0.0 - trackedScrollView.contentInset.top)
    }

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {

        return PanelDefaultModalLayout(height: UIScreen.height * 0.65)
    }
}

class PanelDefaultModalLayout: FloatingPanelLayout {

    let height: CGFloat

    init(height: CGFloat) {
        self.height = height
    }

    var initialPosition: FloatingPanelPosition {
        return .half
    }

    var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    var topInteractionBuffer: CGFloat {
        return 0
    }

    var bottomInteractionBuffer: CGFloat {
        return 0
    }

    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.3
    }

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .half: return height
        default: return nil
        }
    }

}
