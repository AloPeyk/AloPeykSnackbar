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

enum SnackBarPosition : Int {
    case top
    case bottom
}

fileprivate var defaultDurations: [AnyHashable : Any] = [:]
fileprivate let presentationTime: TimeInterval = 0.250
fileprivate var stash: [SnackBarView] = []

class SnackBarView: UIView {
    
    // MARK: - Variables
    fileprivate var pendingOptions: NSDictionary? = [:]
    fileprivate var state: SnackBarState?
    fileprivate var barPosition: SnackBarPosition?
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
    
    fileprivate var fontFamily: String? = "" {
        didSet {
            titleLabel.font = UIFont(name: fontFamily!, size: 16)
            actionButton.titleLabel?.font = UIFont(name: fontFamily!, size: 16)
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
        titleLabel.font = UIFont(name: self.fontFamily ?? "IRANSans", size: 16)
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    // MARK: - Action Button
    fileprivate lazy var actionButton: UIButton = {
        let actionButton = UIButton()
        actionButton.setTitle(self.actionTitle, for: .normal)
        actionButton.titleLabel?.font = UIFont(name: self.fontFamily ?? "IRANSans", size: 16)
        actionButton.addTarget(self, action: #selector(actionPressed), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        return actionButton
    }()
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ActionButton Handker
    func actionPressed() {
        hide()
        callback?()
    }
    
    func configureFrame() {
        if barPosition == .top {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 68)
    
        } else {
        frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 48, width: UIScreen.main.bounds.size.width, height: 48)
        }
        configUI()
    }
    
    // MARK: - SnackBar Handlers
    class func show(withOptions options: NSDictionary?, barPosition: SnackBarPosition, callback: @escaping () -> Void) {
        
        dismiss()
        let b = SnackBarView()
        b.pendingOptions = options
        b.barPosition = barPosition
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
        
        let transitionY = (barPosition == .top) ? -self.bounds.height : self.bounds.height
        self.transform = CGAffineTransform(translationX: 0, y: transitionY)
        titleLabel.alpha = 0
        titleLabel.font = UIFont(name: fontFamily!, size: 16)
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
        
        configureFrame()
        
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
        
        if let font = pendingOptions["fontFamily"] as? NSString {
            self.fontFamily = font as String;
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
            let transitionY = (self.barPosition == .top) ? -self.bounds.height : self.bounds.height
            self.transform = CGAffineTransform(translationX: 0, y: transitionY)    }) { (isDone) in
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
        
        let topMargin: CGFloat
        var bottomMargin: CGFloat
        
        if barPosition == .top {
            
            let modelName = UIDevice.modelName
            switch modelName {
            case "iPhone 4","iPhone 4s", "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone 6", "iPhone 6 Plus", "iPhone 6s", "iPhone 6s Plus", "iPhone 7", "iPhone 7 Plus", "iPhone SE", "iPhone 8", "iPhone 8 Plus":
                topMargin = 30
            default:
                topMargin = 50
            }
            
            bottomMargin = 14
        } else {
            topMargin = 14
            bottomMargin = topMargin
            
            if #available(iOS 11.0, *) {
                if let window = keyWindow, window.safeAreaInsets.bottom > bottomMargin {
                    bottomMargin = window.safeAreaInsets.bottom
                }
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
        if barPosition == .bottom {
            keyWindow?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(>=48)]|", options: [], metrics: nil, views: ["v1": self]))
        }
    }
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
