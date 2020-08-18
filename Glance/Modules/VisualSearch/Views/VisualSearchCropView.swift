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



struct Box : Equatable {
    var x1 : CGFloat
    var y1 : CGFloat
    var x2 : CGFloat
    var y2 : CGFloat
    
    init(rect : CGRect) {
        x1 = rect.origin.x
        y1 = rect.origin.y
        x2 = rect.size.width + x1
        y2 = rect.size.height + y1
    }
    
    static var zero : Box {
        return Box(rect: .zero)
    }
    
    func toArray () -> [CGFloat]{
        return [x1,y1,x2,y2]
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x1 == rhs.x1 && lhs.x2 == rhs.x2 &&  lhs.y1 == rhs.y1 &&  lhs.y2 == rhs.y2
    }

}

class VisualSearchCropView: UIView {
    
    private(set) public var originSize : CGSize = .zero
    private lazy var ltView : VisualSearchClippingCircle = makeClippingCircleView(with: 0)
    private lazy var lbView : VisualSearchClippingCircle = makeClippingCircleView(with: 1)
    private lazy var rtView : VisualSearchClippingCircle = makeClippingCircleView(with: 2)
    private lazy var rbView : VisualSearchClippingCircle = makeClippingCircleView(with: 3)
    private var isInitialize : Bool = false
    
    
    fileprivate var dragging: Bool = false
    fileprivate var initialRect: CGRect = .zero
        
    let boxes = BehaviorRelay<[CGRect]>(value : [])
        
    
    private var selectedBox : UIButton?
    
    
    
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
    
    public let current = BehaviorRelay<Box>(value: .zero)
    
    
    private var clippingRect : CGRect  {
        set{
            var rect = newValue
            
            let minX : CGFloat = 20
            if rect.origin.x < minX {
                rect.origin.x = minX
            }
            let minY : CGFloat = UIApplication.shared.statusBarFrame.height
            if rect.origin.y < minY {
                rect.origin.y = minY
            }

            let rectX : CGFloat = rect.origin.x + rect.size.width
            let maxWidth = bounds.width - minX
            if rectX > maxWidth {
                rect.size.width = rect.width
                rect.origin.x = bounds.width - rect.width - minX
            }

            let rectY : CGFloat = rect.origin.y + rect.size.height
            let maxHeight : CGFloat = bounds.height - minX
            if rectY > maxHeight {
                rect.size.height = rect.height
                rect.origin.y = bounds.height - rect.height  - minX
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
            
            gridLayer.clippingRect = rect
            gridLayer.setNeedsDisplay()
            
            let ptRect = CGRect(x: originSize.width / imageView.width * rect.x,
                              y: originSize.height / imageView.width * rect.y,
                              w: originSize.width / imageView.width * rect.width,
                              h: originSize.height / imageView.width * rect.height)
            
            current.accept(Box(rect: ptRect))
            
        }
        get {
            gridLayer.clippingRect
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
        gridLayer.frame = imageView.bounds
        updateClipping(rect: imageView.bounds, animated: false)
        
        
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
        
        
        boxes.subscribe(onNext: { [weak self](rectItems) in
            self?.showBox(rectItems: rectItems)
        }).disposed(by: rx.disposeBag)
        

        let rect = (0..<5).map {(_) in CGRect(x: CGFloat.random(within: 0...bounds.width), y: CGFloat.random(within: 0...bounds.height), w: CGFloat.random(within: 20...150), h: CGFloat.random(within: 20...150))}
        
        boxes.accept(rect)
    }
    
    
    
    func showBox(rectItems : [CGRect]) {
        
        rectItems.enumerated().forEach { (tag, rect) in
            let box = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 21, height: 21)))
            box.setBackgroundImage(UIImage(color: .white), for: .normal)
            box.setBackgroundImage(UIImage(color: UIColor.primary()), for: .selected)
            box.center = rect.center
            box.adjustsImageWhenHighlighted = false
            box.rx.tap.subscribe(onNext:  {[weak self] () in
                UIView.animate(withDuration: 0.25, animations: {
                    self?.selectedBox?.alpha = 1
                    box.alpha = 0
                    self?.selectedBox = box
                }) { (_) in
                    self?.updateClipping(rect: rect, animated: true)
                }
            }).disposed(by: rx.disposeBag)
            box.layer.cornerRadius = box.height / 2
            box.layer.masksToBounds = true
            box.tag = tag
            imageView.addSubview(box)
        }
    }
}

extension VisualSearchCropView {
    
    func updateImageViewFrame() {
        
        guard image != nil else { return }
        var w = UIScreen.main.bounds.width
        let maxH : CGFloat = bounds.height //- UIApplication.shared.statusBarFrame.height
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
    
    func updateClipping(rect : CGRect, animated : Bool) {
//
//        var rect = rect
//
//        let minX : CGFloat = 20
//        if rect.origin.x < minX {
//            rect.origin.x = minX
//        }
//        let minY : CGFloat = UIApplication.shared.statusBarFrame.height
//        if rect.origin.y < minY {
//            rect.origin.y = minY
//        }
//
//        let maxWidth : CGFloat = bounds.width - (minX * 2.0)
//        if rect.size.width > maxWidth {
//            rect.size.width = maxWidth
//        }
//
//        let maxHeight : CGFloat = bounds.height - minX
//        if rect.size.height > maxHeight {
//            rect.size.height = maxHeight
//        }
//
//
        if animated {
            
            let offset : CGFloat = ltView.lineWidth / 2
            
            var lt = convert(CGPoint(x: rect.origin.x, y: rect.origin.y), from: imageView)
            lt.x -= offset
            lt.y -= offset
            //            ltView.frame.origin = lt
            
            var lb = convert(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height), from: imageView)
            lb.x -= offset
            lb.y -= (lbView.frame.height - offset)
            //            lbView.frame.origin = lb
            
            var rt = convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y), from: imageView)
            rt.x += (offset - rtView.frame.width)
            rt.y -= offset
            //            rtView.frame.origin = rt
            
            var rb = convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height),from: imageView)
            rb.x += (offset - rbView.frame.width)
            rb.y -= (rbView.frame.height - offset)
            //            rbView.frame.origin = rb
            UIView.animate(withDuration: 0.25) {
                
                self.ltView.frame.origin = lt
                self.lbView.frame.origin = lb
                self.rtView.frame.origin = rt
                self.rbView.frame.origin = rb
            }
            
            let animation = CABasicAnimation(keyPath: "clippingRect")
            animation.duration = 0.25;
            animation.fromValue = NSValue(cgRect: .zero)
            animation.toValue = NSValue(cgRect: rect)
            gridLayer.add(animation, forKey: nil)
            gridLayer.clippingRect = rect
            gridLayer.setNeedsDisplay()
            clippingRect = rect
            
        } else {
            clippingRect = rect
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
        
        UIView.animate(withDuration: 0.25) {
            self.selectedBox?.alpha = 1
        }
        
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
        
        UIView.animate(withDuration: 0.25) {
            self.selectedBox?.alpha = 1
        }

        let tag = sender.view?.tag ?? -1
        var point: CGPoint = sender.location(in: imageView)
        let dp: CGPoint = sender.translation(in: imageView)
        
        var rct: CGRect = clippingRect
        
        let W: CGFloat = imageView.frame.size.width
        let H: CGFloat = imageView.frame.size.height
        
        var minX: CGFloat = 20
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
        clippingRect = rct
    }
    
}

extension Reactive where Base: VisualSearchCropView {
    
    var image: Binder<UIImage?> {
        return Binder(self.base) { view, image in
            view.image = image
        }
    }
}
