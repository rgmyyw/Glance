//
//  PopSelectColorView.swift
//  ZHFToolBox
//
//  Created by 张海峰 on 2018/5/30.
//  Copyright © 2018年 张海峰. All rights reserved.
//
/*该demo是和大家分享一下，在项目中自定义各种弹框的思路，用来支撑自己项目的使用，无论什么样的弹框，只要有思路，
 相信大家都能完美实现。感觉我这个demo对你有启发或者帮助，不妨给个星星吧
 https://github.com/FighterLightning/ZHFToolBox.git
 https://www.jianshu.com/p/88420bc4d32d
 */
/*弹出一堆小视图，带回弹*/
import UIKit

protocol PopSomeColorViewDelegate {
    func selectBtnTag(btnTag: NSInteger)
}

private let screenWidth = UIApplication.shared.keyWindow!.bounds.width
private let screenHeight = UIApplication.shared.keyWindow!.bounds.height


class PublishPopView: View {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var delegate:PopSomeColorViewDelegate?
    var animateTime:TimeInterval = 0.5 //动画总时长
    var delyTime:CGFloat = 0.1 //每两个动画间隔时长
    var cancelBtn :UIButton = UIButton()
    var Y : CGFloat = screenHeight * 0.4
    
    let btnWH: CGFloat = (screenWidth - 120)/3
    lazy var btnMarr: NSMutableArray = NSMutableArray()
    
    
    @IBOutlet weak var contentViewBottom: NSLayoutConstraint!
    
    override func makeUI() {
        super.makeUI()
        
        snp.makeConstraints { (make) in
            make.size.equalTo(UIScreen.main.bounds.size)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        let layer = CAShapeLayer()
        let bezier = UIBezierPath()
        
        let curveHeight : CGFloat = 70
        let startY = curveHeight
        
        bezier.move(to: CGPoint.init(x: 0, y: startY))
        bezier.addLine(to: CGPoint(x: 0, y: contentView.height))
        bezier.addLine(to: CGPoint(x: contentView.width, y: contentView.height))
        bezier.addLine(to: CGPoint(x: contentView.width, y: startY))
        bezier.addQuadCurve(to: CGPoint.init(x: 0, y: startY),
                            controlPoint: CGPoint.init(x: contentView.width / 2, y: -startY))
        
        layer.path = bezier.cgPath
        layer.fillColor = UIColor.primary().cgColor
        layer.magnificationFilter = CALayerContentsFilter.nearest;
        layer.contentsScale = UIScreen.main.scale
        layer.lineCap = .round
        layer.lineJoin = .round
        
        //rasterize
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        backgroundColor = .clear
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        contentView.layer.insertSublayer(layer, at: 0)
        backgroundView.rx.tap().subscribe(onNext: { [weak self]() in
            self?.cancelBtnClick(btn: self!.cancelBtn)
        }).disposed(by: rx.disposeBag)
    }
    
    
    
    func addAnimate(){
        
        
        UIApplication.shared.keyWindow?.addSubview(self)
        backgroundView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 0.7
        }
        
        contentViewBottom.constant =  -contentView.frame.height
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5,
                       delay: 0 ,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.contentViewBottom.constant = 0
                        self.contentView.superview?.layoutIfNeeded()
        }, completion: { (_) in })
        
        
//        for i in 0 ..< self.btnMarr.count {
//            let btn: UIButton = self.btnMarr[i] as! UIButton
//            let btnY : CGFloat = btn.frame.origin.y
//            let cancelBtnY :CGFloat =  self.cancelBtn.frame.origin.y
//            UIView.animate(withDuration: self.animateTime, delay: TimeInterval(self.delyTime * CGFloat(i)) , usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseInOut, animations: {
//                btn.frame.origin.y = btnY - self.Y
//            }, completion: { (_) in
//                self.cancelBtn.transform = CGAffineTransform.init(rotationAngle:0)
//                UIView.animate(withDuration: self.animateTime, animations: {
//                    self.cancelBtn.frame.origin.y = cancelBtnY - self.Y
//                    self.cancelBtn.transform = CGAffineTransform.init(rotationAngle:.pi/2)
//                })
//            })
//        }
    }
    @objc func cancelBtnClick(btn: UIButton){
        
        UIView.animate(withDuration: 0.5,
                       delay: 0 ,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.contentViewBottom.constant = -self.contentView.frame.height
                        self.contentView.superview?.layoutIfNeeded()
        }, completion: { (_) in })
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = 0
        }) { (result) in
            self.removeFromSuperview()
        }

        
        
        
        //        if btn != cancelBtn {
        //            self.delegate?.selectBtnTag(btnTag: btn.tag)
        //        }
        //        self.isHidden = false
        //        UIView.animate(withDuration: self.animateTime, animations: {
        //            self.cancelBtn.frame.origin.y += self.Y
        //            self.cancelBtn.transform = CGAffineTransform.init(rotationAngle:0)
        //        }) { (_) in
        //            for i in 0 ..< self.btnMarr.count {
        //                let btn: UIButton = self.btnMarr[self.btnMarr.count - i - 1] as! UIButton;
        //                let btnY : CGFloat = btn.frame.origin.y;
        //                UIView.animate(withDuration: self.animateTime, delay: TimeInterval(self.delyTime * CGFloat(i)) , usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseInOut, animations: {
        //                    btn.frame.origin.y = btnY + self.Y
        //                }, completion: { (_) in
        //                    self.btnMarr = NSMutableArray.init()
        //                    self.removeFromSuperview()
        //                })
        //            }
        //        }
    }
}
