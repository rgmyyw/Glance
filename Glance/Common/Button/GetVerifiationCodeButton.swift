//
//  GetVerifiationCodeButton.swift
//  
//
//  Created by 杨海 on 2020/3/19.
//  Copyright © 2020 . All rights reserved.
//

import UIKit


private let TIME_SECONDS = 120

enum GetVerifiationCodeButtonState  {
    case start
    case end
    case fail
}


class GetVerifiationCodeButton: UIButton {

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.isHidden = true
        return indicator
    }()
    
    
    private var kCountdownTime: TimeInterval = 120
    private var timer: DispatchSourceTimer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setBaseUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setBaseUI()
    }

    
    deinit {
        timer?.cancel()
    }
}

// MARK: - UI
extension GetVerifiationCodeButton {
    
    private func setBaseUI() {
            
        setTitleForAllStates("Resend")
        setTitleColor(UIColor.text(), for: .normal)
        titleLabel?.font = UIFont.titleFont(14)
        
        
        // 添加菊花控件
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    /// 更新UI
    /// - Parameter state: 验证码按钮状态
    func updateUI(withState state: GetVerifiationCodeButtonState) {
        switch state {
        case .start:
            startLoading()
        case .fail:
            stopLoading()
        case .end:
            startCountdown()
        }
    }
}

// MARK: - privateFunc
extension GetVerifiationCodeButton {
    // 开始加载
    private func startLoading() {
        self.setTitle("", for: .normal)
        isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // 结束加载
    private func stopLoading() {
        isEnabled = true
        setTitle("发送验证码", for: .normal)
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
    }
    
    /// 开始倒计时
    private func startCountdown() {
        stopLoading()
        kCountdownTime = TimeInterval(TIME_SECONDS)
        
        isEnabled = false
        // 初始化定时器
        timer = DispatchSource.makeTimerSource()
        
        // 倒计时
        timer?.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.seconds(1))
        timer?.setEventHandler(handler: {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                // 停止计时
                if strongSelf.kCountdownTime == 0 {
                    strongSelf.timer?.cancel()
                    strongSelf.isEnabled = true
                    strongSelf.setTitle("重新发送", for: .normal)
                    return
                }
                
                strongSelf.kCountdownTime -= 1
                let buttonTittle = "\(Int(strongSelf.kCountdownTime))秒后重发"
                strongSelf.setTitleForAllStates(buttonTittle)
            }
        })
        
        timer?.resume()
    }
}
