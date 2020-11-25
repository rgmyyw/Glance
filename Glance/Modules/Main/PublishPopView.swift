import UIKit
import RxSwift
import RxCocoa

protocol PopSomeColorViewDelegate: class {
    func selectBtnTag(btnTag: NSInteger)
}

class PublishPopView: View {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!

    weak var delegate: PopSomeColorViewDelegate?
    var animateTime: TimeInterval = 0.5 //动画总时长
    var delyTime: CGFloat = 0.1 //每两个动画间隔时长
    var cancelBtn: UIButton = UIButton()
    //var y: CGFloat = UIScreen.main.bounds.height * 0.4

    let btnWH: CGFloat = (UIScreen.main.bounds.width - 120)/3
    lazy var btnMarr: NSMutableArray = NSMutableArray()

    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var contentViewBottom: NSLayoutConstraint!

    let selection = PublishSubject<Int>()

    override func makeUI() {
        super.makeUI()

        snp.makeConstraints { (make) in
            make.size.equalTo(UIScreen.main.bounds.size)
        }

        setNeedsLayout()
        layoutIfNeeded()

        let layer = CAShapeLayer()
        let bezier = UIBezierPath()

        let curveHeight: CGFloat = 70
        let startY = curveHeight

        bezier.move(to: CGPoint.init(x: 0, y: startY))
        bezier.addLine(to: CGPoint(x: 0, y: contentView.height))
        bezier.addLine(to: CGPoint(x: contentView.width, y: contentView.height))
        bezier.addLine(to: CGPoint(x: contentView.width, y: startY))
        bezier.addQuadCurve(to: CGPoint.init(x: 0, y: startY),
                            controlPoint: CGPoint.init(x: contentView.width / 2, y: -startY))

        layer.path = bezier.cgPath
        layer.fillColor = UIColor.primary().cgColor
        layer.magnificationFilter = CALayerContentsFilter.nearest
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

        imageViews.tapGesture().bind(to: selection).disposed(by: rx.disposeBag)
        selection.mapToVoid()
            .subscribe(onNext: { [weak self]() in
                self?.cancelBtnClick(btn: self!.cancelBtn)
        }).disposed(by: rx.disposeBag)

    }

    func addAnimate() {

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
    }
    @objc func cancelBtnClick(btn: UIButton) {

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
        }, completion: { (_) in
            self.removeFromSuperview()
        })
    }
}
