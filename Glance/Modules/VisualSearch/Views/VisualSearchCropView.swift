//
//  CropView.swift
//  Image
//
//  Created by yanghai on 2020/7/28.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VisualSearchCropView: UIView {
    
    fileprivate var dragging: Bool = false
    fileprivate var initialRect: CGRect = .zero
    
    private lazy var ltView : VisualSearchClippingCircle = makeClippingCircleView(with: 0)
    private lazy var lbView : VisualSearchClippingCircle = makeClippingCircleView(with: 1)
    private lazy var rtView : VisualSearchClippingCircle = makeClippingCircleView(with: 2)
    private lazy var rbView : VisualSearchClippingCircle = makeClippingCircleView(with: 3)
    
    private var clippingRect : CGRect = .zero
    private var isInitialize : Bool = false
    private let imageViewInset : CGFloat = 20
    private let topInset = UIApplication.shared.statusBarFrame.height
    
    public let current = BehaviorRelay<Box>(value: .zero)
    public let elements = BehaviorRelay<[VisualSearchDotButton]>(value: [])
    
    private(set) public var originSize : CGSize = .zero
    public var image : UIImage? {
        set {
            guard let image = newValue else { return }
            originSize = image.size
            imageView.image = image
            isInitialize = true
            setNeedsLayout()
            sendSubviewToBack(imageView)
        }
        get {
            imageView.image
        }
    }
    
    private(set) public lazy var imageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.isUserInteractionEnabled = true
        addSubview(view)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGridView(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private lazy var gridLayer : VisualSearchGridLayar = {
        let gridLayer = VisualSearchGridLayar()
        gridLayer.bgColor = UIColor.black.withAlphaComponent(0.5)
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
        
        let rect = CGRect(x: imageViewInset, y: topInset, width: imageView.bounds.width - imageViewInset * 2, height: imageView.bounds.height - topInset - imageViewInset)
        gridLayer.frame = imageView.bounds
        updateGridView(rect: rect, animated: true)
        
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
    
    public func selection(dot : VisualSearchDot) {
        if let index = elements.value.firstIndex(where: { $0.dot.box == dot.box}) {
            let item = elements.value[index]
            if item.dot.box != current.value {
                let rect = item.dot.box.transformPt(originSize: originSize, referenceSize: imageView.bounds.size)
                updateGridView(rect: rect, animated: true)
            }
        }
    }
    
    public func updateDots(dots : [VisualSearchDot])  {

        dots.forEach { (dot) in
            var element = elements.value.filter { $0.dot.box == dot.box }.first
            if element == nil {
                print("---------------------------------")
                let rect = dot.box.transformPt(originSize: originSize, referenceSize: imageView.bounds.size)
                print("begin create dot")
                print("current px: \(dot.box.string)")
                print("px -> pt: \(rect.debugDescription)")
                print("pt -> px: \(Box.init(rect: rect).transformPx(originSize: originSize, referenceSize: imageView.size).string)")
                
                element = VisualSearchDotButton(center: rect.center, dot: dot)
                element?.rx.tap.subscribe({ [weak self] _ in
                    self?.updateGridView(rect: rect, animated: true)
                }).disposed(by: rx.disposeBag)
                current.subscribe(onNext: { (box) in
                    element?.dot.current = box
                }).disposed(by: rx.disposeBag)
                imageView.addSubview(element!)
                elements.accept(elements.value + [element!])
                if imageView.subviews.count == 1 {
                    updateGridView(rect: rect, animated: true)
                }
                print("end create dot")
                print("---------------------------------")
            }
            
            print("---------------------------------")
            //element?.view.isSelected = dot.state == .selected
            print("default : \(dot.box.default)")
            print("current state : \(dot.state.value)")
            print("current box : \(dot.box.string)")
            print("selected box: \(dot.current?.string ?? "")")
            print("is current : \(dot.box == dot.current)")
            print("selected product: \(dot.selected?.productId ?? "")")
            print("---------------------------------")
        }

//        // 剔除已经不存在的点...
//        var value = self.dots.value
//        value.removeAll { (box, view) -> Bool in
//            let contains = actions.contains(where: { $0.1 == box})
//            if !contains {
//                view.removeFromSuperview()
//                return true
//            } else {
//                return false
//            }
//        }
//        boxes.accept(value)
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
            h = w * imageHeight / imageWidth
        }
        
        var frame = CGRect(x: 0, y: 0, width: w, height: h)
        frame.origin.x = center.x - w * 0.5
        frame.origin.y = 0
        
        if isInitialize {
            UIView.animate(withDuration: 0.2) {
                self.imageView.frame = frame
            }
        } else {
            imageView.frame = frame
        }
    }
    
    
    func updateGridView (rect :  CGRect , animated : Bool)  {
        
        var rect = rect
        let minX : CGFloat = imageViewInset
        if rect.origin.x < minX {
            rect.origin.x = minX
        }
        let minY : CGFloat = topInset
        if rect.origin.y < minY {
            rect.origin.y = minY
        }
        
        let rectX : CGFloat = rect.origin.x + rect.size.width
        let maxWidth = imageView.bounds.width - minX
        if rectX > maxWidth {
            rect.size.width = rect.width
            rect.origin.x = imageView.bounds.width - rect.width - minX
            if rect.origin.x < minX {
                rect.origin.x = minX
                //rect.size.width = imageView.bounds.width - minX * 2
            }
            
        }
        
        let rectY : CGFloat = rect.origin.y + rect.size.height
        let maxHeight : CGFloat = imageView.bounds.height - minX
        if rectY > maxHeight {
            rect.size.height = rect.height
            rect.origin.y = imageView.bounds.height - rect.height  - minX
            if rect.origin.y < minY {
                rect.origin.y = minY
                //rect.size.height = imageView.bounds.height - minY - minX
            }
            
        }
        
        
        let offset : CGFloat = ltView.lineWidth / 2
        
        var lt = convert(CGPoint(x: rect.origin.x, y: rect.origin.y), from: imageView)
        lt.x -= offset
        lt.y -= offset
        ltView.frame.origin = lt
        
        var lb = convert(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height), from: imageView)
        lb.x -= offset
        lb.y -= (lbView.frame.height - offset)
        lbView.frame.origin = lb
        
        var rt = convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y), from: imageView)
        rt.x += (offset - rtView.frame.width)
        rt.y -= offset
        rtView.frame.origin = rt
        
        var rb = convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height),from: imageView)
        rb.x += (offset - rbView.frame.width)
        rb.y -= (rbView.frame.height - offset)
        rbView.frame.origin = rb
        
        if animated {
            let animation = CABasicAnimation(keyPath: "clippingRect")
            animation.duration = 0.25;
            animation.fromValue = NSValue(cgRect: .zero)
            animation.toValue = NSValue(cgRect: rect)
            gridLayer.add(animation, forKey: nil)
        }
        
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.ltView.frame.origin = lt
            self.lbView.frame.origin = lb
            self.rtView.frame.origin = rt
            self.rbView.frame.origin = rb
            self.gridLayer.clippingRect = rect
            self.gridLayer.setNeedsDisplay()
            
        }) { [weak self](_) in
            self?.clippingRect = rect
            if let originSize = self?.originSize , let imageSize = self?.imageView.bounds.size {
                let box = Box(rect: rect).transformPx(originSize: originSize, referenceSize: imageSize)
                self?.current.accept(box)
            }
        }
        
    }
    
}



extension VisualSearchCropView {
    
    func makeClippingCircleView(with tag : Int) -> VisualSearchClippingCircle {
        
        var corner : UIRectCorner
        switch tag {
        case 0:
            corner = .topLeft
        case 1:
            corner = .bottomLeft
        case 2:
            corner = .topRight
        case 3:
            corner = .bottomRight
        default:
            fatalError()
        }
        
        let view = VisualSearchClippingCircle(corner: corner,frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = UIColor.clear
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
            updateGridView(rect: rct, animated: false)
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
        
        var minX: CGFloat = imageViewInset
        var minY: CGFloat = UIApplication.shared.statusBarFrame.height
        var maxX: CGFloat = W - minX
        var maxY: CGFloat = H - minX
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
        updateGridView(rect: rct, animated: false)
    }
    
}

