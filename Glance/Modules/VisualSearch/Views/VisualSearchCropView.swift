//
//  CropView.swift
//  Image
//
//  Created by yanghai on 2020/7/28.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchCropView: UIView {
    
    private(set) public var originSize : CGSize = .zero
    private lazy var ltView : VisualSearchClippingCircle = makeClippingCircleView(with: 0)
    private lazy var lbView : VisualSearchClippingCircle = makeClippingCircleView(with: 1)
    private lazy var rtView : VisualSearchClippingCircle = makeClippingCircleView(with: 2)
    private lazy var rbView : VisualSearchClippingCircle = makeClippingCircleView(with: 3)
    private var isInitialize : Bool = false
    
    fileprivate var dragging: Bool = false
    fileprivate var initialRect: CGRect = .zero
    
    public var image : UIImage? {
        set {
            originSize = newValue?.size ?? .zero
            imageView.image = newValue
            isInitialize = true
            setNeedsLayout()
            
            sendSubviewToBack(imageView)
        }
        get {
            imageView.image
        }
    }
    
    private var clippingRect : CGRect  {
        set{
            let rect = newValue
            ltView.center = convert(CGPoint(x: rect.origin.x, y: rect.origin.y), from: imageView)
            lbView.center = convert(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height), from: imageView)
            rtView.center = convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y), from: imageView)
            rbView.center = convert(CGPoint(x: rect.origin.x + rect.size.width,
                                            y: rect.origin.y + rect.size.height),from: imageView)
            gridLayer.clippingRect = rect
            gridLayer.setNeedsDisplay()

        }
        get {
            gridLayer.clippingRect
        }
    }
    
    private lazy var imageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        addSubview(view)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGridView(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        return view
    }()
    
    
    private lazy var gridLayer : VisualSearchGridLayar = {
        let gridLayer = VisualSearchGridLayar()
        gridLayer.bgColor = UIColor.black.withAlphaComponent(0.3)
        gridLayer.gridColor = UIColor.clear
        return gridLayer
    }()
    
    
    init(image : UIImage, frame : CGRect) {
        super.init(frame: frame)
        self.image = image
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        updateImageViewFrame()
        gridLayer.frame = imageView.bounds
        updateClipping(rect: imageView.bounds, animated: true)

        
        if isInitialize , imageView.superview != nil {
            initializeUI()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initializeUI() {
        guard image != nil else { return }
        
        
        imageView.layer.addSublayer(gridLayer)
        setNeedsLayout()
        gridLayer.isHidden = false
        
        ltView.isHidden = false
        lbView.isHidden = false
        rtView.isHidden = false
        rbView.isHidden = false
        
        isInitialize = false
    }
    
}

extension VisualSearchCropView {
    
    func updateImageViewFrame() {
        
        guard image != nil else { return }
        var w = UIScreen.main.bounds.width
        let maxH : CGFloat = bounds.height
        let maxW : CGFloat = bounds.width
        
        let imageWidth = originSize.width
        let imageHeight = originSize.height
        
        var h = w * imageHeight / imageWidth
        if h > maxH {
            h = maxH
            w = h * imageWidth / imageHeight
        }
        
        if w > maxW {
            w = maxW
        }
        
        let frame = CGRect(x: 0, y: 0, width: w, height: h)
        if isInitialize {
            UIView.animate(withDuration: 0.2) {
                self.imageView.frame = frame
            }
        } else {
            imageView.frame = frame
        }
    }
    
    func updateClipping(rect : CGRect, animated : Bool) {
        
        let rect = imageView.bounds
        if animated {
            let imageView = self.imageView
            UIView.animate(withDuration: 0.25) {
                self.ltView.center = self.convert(CGPoint(x: rect.origin.x, y: rect.origin.y), from: imageView)
                self.lbView.center = self.convert(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height), from: imageView)
                self.rtView.center = self.convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y), from: imageView)
                self.rbView.center = self.convert(CGPoint(x: rect.origin.x + rect.size.width,
                                                          y: rect.origin.y + rect.size.height),from: imageView)
            }
            let animation = CABasicAnimation(keyPath: "clippingRect")
            animation.duration = 0.2;
            animation.fromValue = NSValue(cgRect: clippingRect)
            animation.toValue = NSValue(cgRect: rect)
            gridLayer.add(animation, forKey: nil)
            gridLayer.clippingRect = rect
            gridLayer.setNeedsDisplay()
            
        } else {
            self.clippingRect = rect
        }
        
    }
    
}


extension VisualSearchCropView {
    
    func makeClippingCircleView(with tag : Int) -> VisualSearchClippingCircle {
        let view = VisualSearchClippingCircle(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = UIColor.clear
        view.bgColor = UIColor.white
        view.tag = tag
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCircleView(_:)))
        view.addGestureRecognizer(panGesture)
        addSubview(view)
        return view
    }
    
    @objc func panGridView(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            let point :  CGPoint = sender.location(in: imageView)
            dragging = clippingRect.contains(point)
            initialRect = clippingRect
        } else if dragging {
            let point : CGPoint = sender.translation(in: imageView)
            let left : CGFloat = CGFloat.minimum(CGFloat.maximum(initialRect.origin.x + point.x, 0), imageView.frame.size.width - initialRect.size.width)
            let top : CGFloat = CGFloat.minimum(CGFloat.maximum(initialRect.origin.y + point.y, 0), imageView.frame.size.height - initialRect.size.height)
            var rct : CGRect = self.clippingRect
            rct.origin.x = left
            rct.origin.y = top
            clippingRect = rct
        }
    }
    
}



extension VisualSearchCropView {
    
    
    // MARK: - 拖动
    @objc func panCircleView(_ sender: UIPanGestureRecognizer) {
        
        let tag = sender.view?.tag ?? -1
        var point: CGPoint = sender.location(in: imageView)
        let dp: CGPoint = sender.translation(in: imageView)
        
        var rct: CGRect = clippingRect
        
        let W: CGFloat = imageView.frame.size.width
        let H: CGFloat = imageView.frame.size.height
        
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        var maxX: CGFloat = W
        var maxY: CGFloat = H
        let ratio: CGFloat = 0
        
        switch tag {
        case 0:
            
            // upper left
            maxX = CGFloat.maximum((rct.origin.x + rct.size.width) - 0.1 * W, 0.1 * W)
            maxY = CGFloat.maximum((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H)
            if ratio != 0 {
                let y0: CGFloat = rct.origin.y - ratio * rct.origin.x
                let x0: CGFloat = -y0 / ratio
                minX = CGFloat.maximum(x0, 0)
                minY = CGFloat.maximum(y0, 0)
                
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                
                if -dp.x * ratio + dp.y > 0 {
                    point.x = (point.y - y0) / ratio
                } else {
                    point.y = point.x * ratio + y0
                }
            } else {
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                
            }
            rct.size.width = rct.size.width-(point.x-rct.origin.x)
            rct.size.height = rct.size.height-(point.y-rct.origin.y)
            rct.origin.x = point.x
            rct.origin.y = point.y
            
        case 1:
            
            // lower left
            maxX = CGFloat.maximum((rct.origin.x + rct.size.width) - 0.1 * W, 0.1 * W)
            minY = CGFloat.maximum(rct.origin.y + 0.1 * H, 0.1 * H)
            if ratio != 0 {
                let y0: CGFloat = (rct.origin.y + rct.size.height) - ratio * rct.origin.x
                let xh: CGFloat = (H - y0) / ratio
                
                minX = CGFloat.maximum(xh, 0)
                maxY = CGFloat.minimum(y0, H)
                
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                
                if -dp.x * ratio + dp.y < 0 {
                    point.x = (point.y - y0) / ratio
                } else {
                    point.y = point.x * ratio + y0
                }
            } else {
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                
            }
            rct.size.width = rct.size.width - (point.x - rct.origin.x)
            rct.size.height = point.y - rct.origin.y
            rct.origin.x = point.x
            
        case 2:
            
            // upper right
            minX = CGFloat.maximum(rct.origin.x + 0.1 * W, 0.1 * W)
            maxY = CGFloat.maximum((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H)
            if ratio != 0 {
                let y0: CGFloat = rct.origin.y - ratio * (rct.origin.x + rct.size.width)
                let yw: CGFloat = ratio * W + y0
                let x0: CGFloat = -y0 / ratio
                
                maxX = CGFloat.minimum(x0, W)
                minY = CGFloat.maximum(yw, 0)
                
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                
                if -dp.x * ratio + dp.y > 0 {
                    point.x = (point.y - y0) / ratio
                } else {
                    point.y = point.x * ratio + y0
                }
            } else {
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                
            }
            rct.size.width = point.x - rct.origin.x
            rct.size.height = rct.size.height - (point.y - rct.origin.y)
            rct.origin.y = point.y
            
        case 3:
            
            // lower right
            minX = CGFloat.maximum(rct.origin.x + 0.1 * W, 0.1 * W)
            minY = CGFloat.maximum(rct.origin.y + 0.1 * H, 0.1 * H)
            if ratio != 0 {
                let y0: CGFloat = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width)
                let yw: CGFloat = ratio * W + y0
                let xh: CGFloat = (H - y0) / ratio
                maxX = CGFloat.minimum(xh, W)
                maxY = CGFloat.minimum(yw, H)
                
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                if -dp.x * ratio + dp.y < 0 {
                    point.x = (point.y - y0) / ratio
                } else {
                    point.y = point.x * ratio + y0
                }
            } else {
                point.x = CGFloat.maximum(minX, CGFloat.minimum(point.x, maxX))
                point.y = CGFloat.maximum(minY, CGFloat.minimum(point.y, maxY))
                
            }
            rct.size.width = point.x - rct.origin.x
            rct.size.height = point.y - rct.origin.y
            
        default:
            break
        }
        clippingRect = rct
    }
    
}
