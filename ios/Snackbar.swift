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
      SnackBarView.show(withOptions: options, callback: {
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
    return ["LENGTH_INDEFINITE": -2, "LENGTH_LONG": 0, "LENGTH_SHORT": -1, "DIRECTION_RTL": "rtl", "DIRECTION_LTR": "ltr"]
  }
  
}


