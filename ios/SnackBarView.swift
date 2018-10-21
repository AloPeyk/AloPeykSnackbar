//
//  SnackBar.swift
//  Tests
//
//  Created by Mohammad Ali on 9/3/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

// MARK: - SnackBarState
enum SnackBarState : Int {
  case displayed
  case presenting
  case dismissing
  case dismissed
}

fileprivate var defaultDurations: [AnyHashable : Any] = [:]
fileprivate let presentationTime: TimeInterval = 0.250
fileprivate var stash: [SnackBarView] = []

class SnackBarView: UIView {
  
  // MARK: - Variables
  fileprivate var pendingOptions: NSDictionary? = [:]
  fileprivate var state: SnackBarState?
  fileprivate var pendingCallback: (() -> Void)?
  fileprivate var callback: (() -> Void)?
  fileprivate var hideTimer: Timer?

  fileprivate lazy var keyWindow: UIWindow? = {
    return UIApplication.shared.keyWindow
  }()
  
  fileprivate var title: String? = "" {
    didSet {
      titleLabel.text = title
    }
  }
  
  fileprivate var actionTitle: String? = "" {
    didSet {
      actionButton.setTitle(actionTitle, for: .normal)
    }
  }
  
  fileprivate var actionTitleColor: UIColor? {
    didSet {
      actionButton.setTitleColor(actionTitleColor, for: .normal)
    }
  }
  
  fileprivate var titleLabelColor: UIColor = .white {
    didSet {
      titleLabel.textColor = titleLabelColor
    }
  }
  
  fileprivate var direction: String = "ltr" {
    didSet {
      setDirection(direction)
    }
  }
    
  // MARK: - TitleLabel
  fileprivate lazy var titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.text = self.title
    titleLabel.numberOfLines = 0
    titleLabel.font = UIFont(name: "IRANSans", size: 16)
    titleLabel.textColor = UIColor.white
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    return titleLabel
  }()
  
  // MARK: - Action Button
  fileprivate lazy var actionButton: UIButton = {
    let actionButton = UIButton()
    actionButton.setTitle(self.actionTitle, for: .normal)
    actionButton.titleLabel?.font = UIFont(name: "IRANSans", size: 16)
    actionButton.addTarget(self, action: #selector(actionPressed), for: .touchUpInside)
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    return actionButton
  }()
  
  // MARK: - Initializer
  init() {
    super.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 48, width: UIScreen.main.bounds.size.width, height: 48))
    configUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - ActionButton Handker
  func actionPressed() {
    hide()
    callback?()
  }
  
  // MARK: - SnackBar Handlers
  class func show(withOptions options: NSDictionary?, callback: @escaping () -> Void) {
    dismiss()
    let b = SnackBarView()
    b.pendingOptions = options
    b.pendingCallback = callback
    stash.append(b)
    b.show()
  }

  class func dismiss() {
    for snackBarView in stash {
        snackBarView.hide()
    }
    stash.removeAll()
  }
  
  // MARK: - Pops Up SnackBar
  fileprivate func present(withDuration duration: NSNumber) {
    pendingOptions = nil
    pendingCallback = nil
    
    addConstraintsOfSelfToSuperView()
    
    self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
    titleLabel.alpha = 0
    actionButton.alpha = 0
    state = .presenting
    
    UIView.animate(withDuration: presentationTime, animations: {
      self.transform = .identity
      self.titleLabel.alpha = 1
      self.actionButton.alpha = 1
      
    }) { (finished) in
      self.state = .displayed
      var interval: TimeInterval
      
      if duration.doubleValue <= 0 {
        interval = TimeInterval(defaultDurations[duration.stringValue] as? NSNumber ?? 1) / 1000
      } else {
        interval = duration.doubleValue / 1000
      }
      
      self.hideTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.hide), userInfo: nil, repeats: false)
    }
    
  }
  
  // MARK: - Objective C Type Setters
  func setTitle(_ title: String) {
    titleLabel.text = title
  }
  
  func setActionTitle(_ actionTitle: String) {
    actionButton.setTitle(actionTitle, for: .normal)
  }
  
  func setActionTitleColor(_ actionTitleColor: UIColor) {
    actionButton.setTitleColor(actionTitleColor, for: .normal)
  }
  
  func setTitleLabelColor(_ color: UIColor) {
    titleLabel.textColor = color
  }
  
  func setDirection(_ dir: String) {
    if dir == "rtl" {
      if #available(iOS 9.0, *) {
        semanticContentAttribute = .forceRightToLeft
        titleLabel.textAlignment = .right
      }
    } else {
      titleLabel.textAlignment = .justified
    }
  }
  
}

// MARK: - Animating SnackBar [present, diismiss]
extension SnackBarView {
  
  // MARK: - SnackBar Presentation Handler
  fileprivate func show() {
    if state == .displayed || state == .presenting {
      self.hide()
      return
    }
    
    if state == .dismissing {
      return
    }
    
    guard let pendingOptions = pendingOptions else { return }

    callback = pendingCallback
    
    if let bgColor = pendingOptions["backgroundColor"] as? NSNumber {
      self.backgroundColor = RCTConvert.uiColor(bgColor)
    }

    self.title = pendingOptions["title"] as? String ?? ""
    
    self.direction = pendingOptions["direction"] as? String  ?? "ltr"
    
    if let color = pendingOptions["color"] as? NSNumber {
      titleLabel.textColor = RCTConvert.uiColor(color)
    }

    if let action = pendingOptions["action"] as? NSDictionary {
      actionTitle = action["title"] as? String ?? ""
      
      if let color = action["color"] as? NSNumber {
        setActionTitleColor(RCTConvert.uiColor(color))
      }

    }
    
    let duration = (pendingOptions["duration"] != nil) ? (pendingOptions["duration"] as? NSNumber ?? 0) : -1
    
    present(withDuration: duration)
  }

  // MARK: - Dissmiss Handler
  @objc fileprivate func hide() {
    self.layer.removeAllAnimations()
    hideTimer?.invalidate()
    
    if state == nil || state == .dismissed {
      return
    }

    state = .dismissing
    
    UIView.animate(withDuration: presentationTime, animations: {
      self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
    }) { (isDone) in
      self.state = .dismissed
      self.removeFromSuperview()
      if (self.pendingOptions != nil) {
        self.show()
      }
    }
  }
}

// MARK: - SubView Setup Methods
extension SnackBarView {
  
  // MARK: - Initialize Subviews
  fileprivate func configUI() {
    let topMargin: CGFloat = 14
    var bottomMargin = topMargin
    
    if #available(iOS 11.0, *) {
      if let window = keyWindow, window.safeAreaInsets.bottom > bottomMargin {
        bottomMargin = window.safeAreaInsets.bottom
      }
    }
    
    self.backgroundColor = UIColor(red: 0.196078, green: 0.196078, blue: 0.196078, alpha: 1)
    self.accessibilityIdentifier = "snackbar"
    
    addConstraintsToSubViews(topMargin: topMargin, bottomMargin: bottomMargin)
    
    defaultDurations = ["-2": Int.max, "-1": 1500, "0": 2750]
  }
  
  // MARK: - Constraints for titleLabel and actionButton
  fileprivate func addConstraintsToSubViews(topMargin: CGFloat, bottomMargin: CGFloat) {
    self.addSubview(titleLabel)
    self.addSubview(actionButton)
    
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v1]-20-[v2]-20-|", options: [], metrics: nil, views: ["v1": titleLabel, "v2": actionButton]))
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(topMargin)-[v1]-\(bottomMargin)-|", options: [], metrics: nil, views: ["v1": titleLabel]))
    self.addConstraint(NSLayoutConstraint(item: actionButton, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
    
    
    
    titleLabel.setContentCompressionResistancePriority(UILayoutPriority(250), for: .horizontal)
    titleLabel.setContentHuggingPriority(UILayoutPriority(250), for: .horizontal)
    actionButton.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
    actionButton.setContentHuggingPriority(UILayoutPriority(750), for: .horizontal)
  }
  
  // MARK: - Sets Constraints to SnackBarView
  fileprivate func addConstraintsOfSelfToSuperView() {
    keyWindow?.addSubview(self)
    
    self.translatesAutoresizingMaskIntoConstraints = false
    keyWindow?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v1]|", options: [], metrics: nil, views: ["v1": self]))
    keyWindow?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(>=48)]|", options: [], metrics: nil, views: ["v1": self]))
  }
}
