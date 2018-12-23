//
//  Snackbar.swift
//  Tests
//
//  Created by Mohammad Ali on 9/3/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

@objc(Snackbar)
class Snackbar: NSObject {
  
    func show(_ options: NSDictionary, withCallback callback: @escaping RCTResponseSenderBlock) {
        DispatchQueue.main.async {
            let direction = ((options.object(forKey: "position")) != nil) ? self.directionFor(number: options.object(forKey: "position") as! Int) : SnackBarPosition.top
            SnackBarView.show(withOptions: options, barPosition: direction, callback: {
                callback([NSNull(), NSNull()])
            })
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            SnackBarView.dismiss()
        }
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    func constantsToExport() -> NSDictionary {
        return ["LENGTH_INDEFINITE": -2, "LENGTH_LONG": 0, "LENGTH_SHORT": -1, "DIRECTION_RTL": "rtl", "DIRECTION_LTR": "ltr", "BAR_POSITION_TOP": 0 ,  "BAR_POSITION_BOTTOM": 1]
    }
    
    private func directionFor(number: Int) -> SnackBarPosition {
        switch number {
        case 0:
            return SnackBarPosition.top
        case 1:
            return SnackBarPosition.bottom
        default:
            return SnackBarPosition.top
        }
    }
    
  
}


