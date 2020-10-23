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
import ChameleonFramework

class VisualSearchCropView: UIView {
    
    fileprivate var dragging: Bool = false
    fileprivate var initialRect: CGRect = .zero
    
    private lazy var ltView : VisualSearchClippingCircle = makeClippingCircleView(with: 0)
    private lazy var lbView : VisualSearchClippingCircle = makeClippingCircleView(with: 1)
    private lazy var rtView : VisualSearchClippingCircle = makeClippingCircleView(with: 2)
    private lazy var rbView : VisualSearchClippingCircle = makeClippingCircleView(with: 3)
    
    private var clippingRect : CGRect = .zero
    private var isInitialize : Bool = false
    private let imageViewInset : CGFloat = 10
    private let topInset : CGFloat = UIApplication.shared.statusBarFrame.height
    
    public let current = BehaviorRelay<Box>(value: .zero)
    public let elements = BehaviorRelay<[VisualSearchDotButton]>(value: [])

    private lazy var contentView : UIScrollView = {
        let view = UIScrollView(frame: bounds)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.addSubview(imageView)
        if #available(iOS 11, *) {
            view.contentInsetAdjustmentBehavior = .never
        } else {
            
        }
        return view
    }()
    
    private(set) public lazy var imageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.isUserInteractionEnabled = false
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
        
    
    public var imageSize : CGSize  {
        return image?.size ?? .zero
    }
    
    public var image : UIImage? {
        set {
            guard let image = newValue else { return }
            imageView.image = image
            isInitialize = true
            setNeedsLayout()
            if contentView.superview == nil {
                addSubview(contentView)
            }
            sendSubviewToBack(contentView)
            backgroundColor = UIColor(averageColorFrom: image)
        }
        get {
            imageView.image
        }
    }
    
    init(image : UIImage, frame : CGRect) {
        super.init(frame: frame)
        self.image = image
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateImageViewFrame()
        
        let height = imageView.bounds.height - topInset - imageViewInset
        let width = imageView.bounds.width - imageViewInset * 2
        let rect = CGRect(x: imageViewInset, y: topInset, width: width, height: height)
        
        updateGridView(rect: rect, animated: true)
        
        if isInitialize , imageView.superview != nil {
            initializeUI()
        }
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
    
        imageView.rx.observeWeakly(CGRect.self, "frame", options: .new)
            .subscribe(onNext: { [weak self](frame) in
                guard let self = self ,let frame = frame else { return }
                self.contentView.contentSize = frame.size
                self.gridLayer.frame = frame.height < self.frame.height ? self.frame : frame
            }).disposed(by: rx.disposeBag)
        
    }
    
    public func selection(dot : VisualSearchDotCellViewModel) {
        if let index = elements.value.firstIndex(where: { $0.dot.box == dot.box}) {
            let item = elements.value[index]
            if item.dot.box != current.value {
                let rect = item.dot.box.transformCGRect(from: imageSize)
                updateGridView(rect: rect, animated: true)
            }
        }
    }
    
    public func updateDots(dots : [VisualSearchDotCellViewModel])  {

        dots.forEach { (dot) in
            var element = elements.value.filter { $0.dot.box == dot.box }.first
            if element == nil {
                print("---------------------------------")
                let rect = dot.box.transformCGRect(from: imageSize)
                print("begin create dot")
                print("current px: \(dot.box.string)")
                print("px -> pt: \(rect.debugDescription)")
                print("pt -> px: \(rect.transformPixel(from: imageSize).string)")
                
                element = VisualSearchDotButton(center: rect.center, dot: dot)
                element?.rx.tap.subscribe({ [weak self] _ in
                    self?.updateGridView(rect: rect, animated: true)
                }).disposed(by: rx.disposeBag)
                current.subscribe(onNext: { (box) in
                    element?.dot.current = box
                }).disposed(by: rx.disposeBag)
                contentView.addSubview(element!)
                elements.accept(elements.value + [element!])
                if elements.value.count == 1 {
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
    }
}

extension VisualSearchCropView {
    
    func updateImageViewFrame() {
        
        guard image != nil else { return }
        let maxW : CGFloat = bounds.width
        //let maxH : CGFloat = bounds.height 

        let imgW = imageSize.width
        let imgH = imageSize.height
        
        /// 如果图片大于屏幕宽度，缩小宽度, 高度也对应的缩小
        /// 如果图片小于屏幕宽度，放大宽度, 高度也对应放大
        let h = maxW * imgH / imgW
//        if h > maxH {
//            h = maxH
//            w = h * imgW / imgH
//        }
        
        var frame = CGRect(x: 0, y: 0, width: maxW, height: h)
        frame.origin.x = center.x - maxW * 0.5
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
        
        let offset : CGFloat = ltView.lineWidth / 2
        let fromView : UIView = contentView
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
        let maxWidth = contentView.contentSize.width - minX
        if rectX > maxWidth {
            rect.size.width = maxWidth - rect.origin.x
        }
        
        let rectY : CGFloat = rect.origin.y + rect.size.height
        let maxHeight : CGFloat = contentView.contentSize.height - minX
        if rectY > maxHeight {
            rect.size.height = maxHeight - rect.origin.y
        }
        
        var lt = contentView.convert(CGPoint(x: rect.origin.x, y: rect.origin.y), from: fromView)
        lt.x -= offset
        lt.y -= offset
        
        var lb = contentView.convert(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height), from: fromView)
        lb.x -= offset
        lb.y -= (lbView.frame.height - offset)
        
        var rt = contentView.convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y), from: fromView)
        rt.x += (offset - rtView.frame.width)
        rt.y -= offset
        
        var rb = contentView.convert(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height),from: fromView)
        rb.x += (offset - rbView.frame.width)
        rb.y -= (rbView.frame.height - offset)
        
        
        if animated {
            
            UIView.animate(withDuration: 0.25) {
                self.ltView.frame.origin = lt
                self.lbView.frame.origin =  lb
                self.rtView.frame.origin =  rt
                self.rbView.frame.origin =  rb
            }

            let animation = CABasicAnimation(keyPath: "clippingRect")
            animation.duration = 0.5;
            animation.fromValue = NSValue(cgRect: CGRect(origin: rect.center, size: .zero))
            animation.toValue = NSValue(cgRect: rect)
            gridLayer.add(animation, forKey: nil)
            
        } else {
            self.ltView.frame.origin = lt
            self.lbView.frame.origin =  lb
            self.rtView.frame.origin =  rt
            self.rbView.frame.origin =  rb
        }
        
        clippingRect = rect
        gridLayer.clippingRect = clippingRect
        
        gridLayer.setNeedsDisplay()
        gridLayer.needsDisplay()
        
        let box = rect.transformPixel(from: imageSize)
        current.accept(box)
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
        contentView.addSubview(view)
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
        var point: CGPoint = sender.location(in: contentView)
        let dp: CGPoint = sender.translation(in: contentView)
        
        var rct: CGRect = clippingRect
        
        let W: CGFloat = contentView.contentSize.width
        let H: CGFloat = contentView.contentSize.height
        
        var minX: CGFloat = imageViewInset
        var minY: CGFloat = topInset
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
        updateGridView(rect: rct, animated: false)
    }
    
}

