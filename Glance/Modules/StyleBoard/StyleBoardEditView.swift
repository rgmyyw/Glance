//
//  StyleBoardEditView.swift
//  Glance
//
//  Created by yanghai on 2020/8/13.
//  Copyright © 2020 yanghai. All rights reserved.
//


import UIKit

enum StyleBoardEditViewHandler:Int {
    case close = 0
    case rotate
    case flip
    case edit
}

enum EditViewPosition:Int {
    case topLeft = 0
    case topRight
    case bottomLeft
    case bottomRight
}

@inline(__always) func CGRectGetCenter(_ rect:CGRect) -> CGPoint {
    return CGPoint(x: rect.midX, y: rect.midY)
}

@inline(__always) func CGRectScale(_ rect:CGRect, wScale:CGFloat, hScale:CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * wScale, height: rect.size.height * hScale)
}

@inline(__always) func CGAffineTransformGetAngle(_ t:CGAffineTransform) -> CGFloat {
    return atan2(t.b, t.a)
}

@inline(__always) func CGPointGetDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let fx = point2.x - point1.x
    let fy = point2.y - point1.y
    return sqrt(fx * fx + fy * fy)
}

protocol StyleBoardEditViewDelegate : class {
    func styleBoardEditViewDidBeginMoving(_ editView: StyleBoardEditView)
    func styleBoardEditViewDidChangeMoving(_ editView: StyleBoardEditView)
    func styleBoardEditViewDidEndMoving(_ editView: StyleBoardEditView)
    func styleBoardEditViewDidBeginRotating(_ editView: StyleBoardEditView)
    func styleBoardEditViewDidChangeRotating(_ editView: StyleBoardEditView)
    func styleBoardEditViewDidEndRotating(_ editView: StyleBoardEditView)
    func styleBoardEditViewDidClose(_ editView: StyleBoardEditView)
    func styleBoardEditViewDidTap(_ editView: StyleBoardEditView)
}

extension StyleBoardEditViewDelegate  {
    
    
    func styleBoardEditViewDidBeginMoving(_ editView: StyleBoardEditView) {
        
    }
    
    func styleBoardEditViewDidChangeMoving(_ editView: StyleBoardEditView){
        
    }
    func styleBoardEditViewDidEndMoving(_ editView: StyleBoardEditView){
        
    }
    
    func styleBoardEditViewDidBeginRotating(_ editView: StyleBoardEditView){
        
    }
    func styleBoardEditViewDidChangeRotating(_ editView: StyleBoardEditView){
        
    }
    
    func styleBoardEditViewDidEndRotating(_ editView: StyleBoardEditView){
        
    }
    func styleBoardEditViewDidClose(_ editView: StyleBoardEditView){
        
    }
    
    func styleBoardEditViewDidTap(_ editView: StyleBoardEditView){
        
    }

}



class StyleBoardEditView: UIView {
    var delegate: StyleBoardEditViewDelegate!
    /// The contentView inside the sticker view.
    var contentView:UIView!
    /// Enable the close handler or not. Default value is YES.
    var enableClose:Bool = true {
        didSet {
            if self.showEditingHandlers {
                self.setEnableClose(self.enableClose)
            }
        }
    }
    /// Enable the rotate/resize handler or not. Default value is YES.
    var enableRotate:Bool = true{
        didSet {
            if self.showEditingHandlers {
                self.setEnableRotate(self.enableRotate)
            }
        }
    }
    /// Enable the flip handler or not. Default value is YES.
    var enableFlip:Bool = true
    /// Enable the edit handler or not. Default value is YES.
    var enableEdit:Bool = true
    
    
    /// Show close and rotate/resize handlers or not. Default value is YES.
    var showEditingHandlers:Bool = true {
        didSet {
            if self.showEditingHandlers {
                self.setEnableClose(self.enableClose)
                self.setEnableRotate(self.enableRotate)
                self.setEnableFlip(self.enableFlip)
                self.setEnableEdit(self.enableEdit)
                self.contentView?.layer.borderWidth = _outlineBorderWidth
            }
            else {
                self.setEnableClose(false)
                self.setEnableRotate(false)
                self.setEnableFlip(false)
                self.setEnableEdit(false)
                self.contentView?.layer.borderWidth = 0
            }
        }
    }
    
    /// Minimum value for the shorter side while resizing. Default value will be used if not set.
    private var _minimumSize:NSInteger = 0
    var minimumSize:NSInteger {
        set {
            _minimumSize = max(newValue, self.defaultMinimumSize)
        }
        get {
            return _minimumSize
        }
    }
    /// Color of the outline border. Default: brown color.
    private var _outlineBorderColor:UIColor = .clear
    var outlineBorderColor:UIColor {
        set {
            _outlineBorderColor = newValue
            self.contentView?.layer.borderColor = _outlineBorderColor.cgColor
        }
        get {
            return _outlineBorderColor
        }
    }
    
    
    private var _outlineBorderWidth:CGFloat = 1
    var outlineBorderWidth:CGFloat {
        set {
            _outlineBorderWidth = newValue
            self.contentView?.layer.borderWidth = newValue
        }
        get {
            return _outlineBorderWidth
        }
    }
    
    
    
    /// A convenient property for you to store extra information.
    var userInfo:Any?
    
    /**
     *  Initialize a sticker view. This is the designated initializer.
     *
     *  @param contentView The contentView inside the sticker view.
     *                     You can access it via the `contentView` property.
     *
     *  @return The sticker view.
     */
    init(contentView: UIView) {
        self.defaultInset = 11
        self.defaultMinimumSize = 4 * self.defaultInset
        
        var frame = contentView.frame
        frame = CGRect(x: 0, y: 0, width: frame.size.width + CGFloat(self.defaultInset) * 2, height: frame.size.height + CGFloat(self.defaultInset) * 2)
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addGestureRecognizer(self.moveGesture)
        self.addGestureRecognizer(self.tapGesture)
        
        // Setup content view
        self.contentView = contentView
        self.contentView.center = CGRectGetCenter(self.bounds)
        self.contentView.isUserInteractionEnabled = false
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.layer.allowsEdgeAntialiasing = true
        

        
        
        self.addSubview(self.contentView)
        
        // Setup editing handlers
        self.setPosition(.topLeft, forHandler: .close)
        self.addSubview(self.closeImageView)
        self.setPosition(.bottomRight, forHandler: .rotate)
        self.addSubview(self.rotateImageView)
        self.setPosition(.bottomLeft, forHandler: .flip)
        self.addSubview(self.flipImageView)
        self.setPosition(.topRight, forHandler: .edit)
        self.addSubview(self.editImageView)

        
        
        self.showEditingHandlers = true
        self.enableClose = true
        self.enableRotate = true
        self.enableFlip = true
        self.enableEdit = true

        self.minimumSize = self.defaultMinimumSize
        self.outlineBorderColor = .brown
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     *  Use image to customize each editing handler.
     *  It is your responsibility to set image for every editing handler.
     *
     *  @param image   The image to be used.
     *  @param handler The editing handler.
     */
    func setImage(_ image:UIImage, forHandler handler:StyleBoardEditViewHandler) {
        switch handler {
        case .close:
            self.closeImageView.image = image
        case .rotate:
            self.rotateImageView.image = image
        case .flip:
            self.flipImageView.image = image
        case .edit:
            self.editImageView.image = image
        }
    }
    
    /**
     *  Customize each editing handler's position.
     *  If not set, default position will be used.
     *  @note  It is your responsibility not to set duplicated position.
     *
     *  @param position The position for the handler.
     *  @param handler  The editing handler.
     */
    func setPosition(_ position:EditViewPosition, forHandler handler:StyleBoardEditViewHandler) {
        let origin = self.contentView.frame.origin
        let size = self.contentView.frame.size
        
        var handlerView:UIImageView?
        switch handler {
        case .close:
            handlerView = self.closeImageView
        case .rotate:
            handlerView = self.rotateImageView
        case .flip:
            handlerView = self.flipImageView
        case .edit:
            handlerView = self.editImageView

        }
        
        switch position {
        case .topLeft:
            handlerView?.center = origin
            handlerView?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        case .topRight:
            handlerView?.center = CGPoint(x: origin.x + size.width, y: origin.y)
            handlerView?.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        case .bottomLeft:
            handlerView?.center = CGPoint(x: origin.x, y: origin.y + size.height)
            handlerView?.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        case .bottomRight:
            handlerView?.center = CGPoint(x: origin.x + size.width, y: origin.y + size.height)
            handlerView?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        }
        
        handlerView?.tag = position.rawValue
    }
    
    /**
     *  Customize handler's size
     *
     *  @param size Handler's size
     */
    func setHandlerSize(_ size:Int) {
        if size <= 0 {
            return
        }
        
        self.defaultInset = NSInteger(round(Float(size) / 2))
        self.defaultMinimumSize = 4 * self.defaultInset
        self.minimumSize = max(self.minimumSize, self.defaultMinimumSize)
        
        let originalCenter = self.center
        let originalTransform = self.transform
        var frame = self.contentView.frame
        frame = CGRect(x: 0, y: 0, width: frame.size.width + CGFloat(self.defaultInset) * 2, height: frame.size.height + CGFloat(self.defaultInset) * 2)
        
        self.contentView.removeFromSuperview()
        
        self.transform = CGAffineTransform.identity
        self.frame = frame
        
        self.contentView.center = CGRectGetCenter(self.bounds)
        self.addSubview(self.contentView)
        self.sendSubviewToBack(self.contentView)
        
        let handlerFrame = CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2)
        self.closeImageView.frame = handlerFrame
        self.setPosition(EditViewPosition(rawValue: self.closeImageView.tag)!, forHandler: .close)
        self.rotateImageView.frame = handlerFrame
        self.setPosition(EditViewPosition(rawValue: self.rotateImageView.tag)!, forHandler: .rotate)
        self.flipImageView.frame = handlerFrame
        self.setPosition(EditViewPosition(rawValue: self.flipImageView.tag)!, forHandler: .flip)
        self.editImageView.frame = handlerFrame
        self.setPosition(EditViewPosition(rawValue: self.editImageView.tag)!, forHandler: .edit)

        
        self.center = originalCenter
        self.transform = originalTransform
    }
    
    /**
     *  Default value
     */
    private var defaultInset:NSInteger
    private var defaultMinimumSize:NSInteger
    
    /**
     *  Variables for moving view
     */
    private var beginningPoint = CGPoint.zero
    private var beginningCenter = CGPoint.zero
    
    /**
     *  Variables for rotating and resizing view
     */
    private var initialBounds = CGRect.zero
    private var initialDistance:CGFloat = 0
    private var deltaAngle:CGFloat = 0
    
    private lazy var moveGesture = {
        return UIPanGestureRecognizer(target: self, action: #selector(handleMoveGesture(_:)))
    }()
    private lazy var rotateImageView:UIImageView = {
        let rotateImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        rotateImageView.contentMode = UIView.ContentMode.scaleAspectFit
        rotateImageView.backgroundColor = UIColor.clear
        rotateImageView.isUserInteractionEnabled = true
        rotateImageView.addGestureRecognizer(self.rotateGesture)
        
        return rotateImageView
    }()
    private lazy var rotateGesture = {
        return UIPanGestureRecognizer(target: self, action: #selector(handleRotateGesture(_:)))
    }()
    private lazy var closeImageView:UIImageView = {
        let closeImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        closeImageview.contentMode = UIView.ContentMode.scaleAspectFit
        closeImageview.backgroundColor = UIColor.clear
        closeImageview.isUserInteractionEnabled = true
        closeImageview.addGestureRecognizer(self.closeGesture)
        return closeImageview
    }()
    private lazy var closeGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleCloseGesture(_:)))
    }()
    private lazy var flipImageView:UIImageView = {
        let flipImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        flipImageView.contentMode = UIView.ContentMode.scaleAspectFit
        flipImageView.backgroundColor = UIColor.clear
        flipImageView.isUserInteractionEnabled = true
        flipImageView.addGestureRecognizer(self.flipGesture)
        return flipImageView
    }()
    private lazy var flipGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleFlipGesture(_:)))
    }()
    
    private lazy var editImageView:UIImageView = {
        let StyleBoardEditView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        StyleBoardEditView.contentMode = UIView.ContentMode.scaleAspectFit
        StyleBoardEditView.backgroundColor = UIColor.clear
        StyleBoardEditView.isUserInteractionEnabled = true
        StyleBoardEditView.addGestureRecognizer(self.editGesture)
        return StyleBoardEditView
    }()
    private lazy var editGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleEditGesture(_:)))
    }()

    
    
    private lazy var tapGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    }()
    // MARK: - Gesture Handlers
    @objc
    func handleMoveGesture(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: self.superview)
        switch recognizer.state {
        case .began:
            self.beginningPoint = touchLocation
            self.beginningCenter = self.center
            if let delegate = self.delegate {
                delegate.styleBoardEditViewDidBeginMoving(self)
            }
        case .changed:
            self.center = CGPoint(x: self.beginningCenter.x + (touchLocation.x - self.beginningPoint.x), y: self.beginningCenter.y + (touchLocation.y - self.beginningPoint.y))
            if let delegate = self.delegate {
                delegate.styleBoardEditViewDidChangeMoving(self)
            }
        case .ended:
            self.center = CGPoint(x: self.beginningCenter.x + (touchLocation.x - self.beginningPoint.x), y: self.beginningCenter.y + (touchLocation.y - self.beginningPoint.y))
            if let delegate = self.delegate {
                delegate.styleBoardEditViewDidEndMoving(self)
            }
        default:
            break
        }
    }
    
    @objc
    func handleRotateGesture(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: self.superview)
        let center = self.center
        
        switch recognizer.state {
        case .began:
            self.deltaAngle = CGFloat(atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))) - CGAffineTransformGetAngle(self.transform)
            self.initialBounds = self.bounds
            self.initialDistance = CGPointGetDistance(point1: center, point2: touchLocation)
            if let delegate = self.delegate {
                delegate.styleBoardEditViewDidBeginRotating(self)
            }
        case .changed:
            let angle = atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))
            let angleDiff = Float(self.deltaAngle) - angle
            self.transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
            
            var scale = CGPointGetDistance(point1: center, point2: touchLocation) / self.initialDistance
            let minimumScale = CGFloat(self.minimumSize) / min(self.initialBounds.size.width, self.initialBounds.size.height)
            scale = max(scale, minimumScale)
            let scaledBounds = CGRectScale(self.initialBounds, wScale: scale, hScale: scale)
            self.bounds = scaledBounds
            self.setNeedsDisplay()
            
            if let delegate = self.delegate {
                delegate.styleBoardEditViewDidChangeRotating(self)
            }
        case .ended:
            if let delegate = self.delegate {
                delegate.styleBoardEditViewDidEndRotating(self)
            }
        default:
            break
        }
    }
    
    @objc
    func handleCloseGesture(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.styleBoardEditViewDidClose(self)
        }
        self.removeFromSuperview()
    }
    
    @objc
    func handleFlipGesture(_ recognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.transform = self.contentView.transform.scaledBy(x: -1, y: 1)
        }
    }
    
    @objc
    func handleEditGesture(_ recognizer: UITapGestureRecognizer) {
        
        
        ///
        
    }

    
    @objc
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.styleBoardEditViewDidTap(self)
        }
    }
    
    // MARK: - Private Methods
    private func setEnableClose(_ enableClose:Bool) {
        self.closeImageView.isHidden = !enableClose
        self.closeImageView.isUserInteractionEnabled = enableClose
    }
    
    private func setEnableRotate(_ enableRotate:Bool) {
        self.rotateImageView.isHidden = !enableRotate
        self.rotateImageView.isUserInteractionEnabled = enableRotate
    }
    
    private func setEnableFlip(_ enableFlip:Bool) {
        self.flipImageView.isHidden = !enableFlip
        self.flipImageView.isUserInteractionEnabled = enableFlip
    }
    
    private func setEnableEdit(_ enableEdit:Bool) {
        self.editImageView.isHidden = !enableEdit
        self.editImageView.isUserInteractionEnabled = enableEdit
    }

}

extension StyleBoardEditView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /**
         * ref: http://stackoverflow.com/questions/19095165/should-superviews-gesture-cancel-subviews-gesture-in-ios-7/
         *
         * The `gestureRecognizer` would be either closeGestureRecognizer or rotateGestureRecognizer,
         * `otherGestureRecognizer` should work only when `gestureRecognizer` is failed.
         * So, we always return YES here.
         */
        return true
    }
}
