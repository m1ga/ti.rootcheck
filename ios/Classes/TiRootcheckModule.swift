//
//  TiRootcheckModule.swift
//  ti.rootcheck
//
//  Created by Your Name
//  Copyright (c) 2022 Your Company. All rights reserved.
//

import UIKit
import TitaniumKit

/**
 
 Titanium Swift Module Requirements
 ---
 
 1. Use the @objc annotation to expose your class to Objective-C (used by the Titanium core)
 2. Use the @objc annotation to expose your method to Objective-C as well.
 3. Method arguments always have the "[Any]" type, specifying a various number of arguments.
 Unwrap them like you would do in Swift, e.g. "guard let arguments = arguments, let message = arguments.first"
 4. You can use any public Titanium API like before, e.g. TiUtils. Remember the type safety of Swift, like Int vs Int32
 and NSString vs. String.
 
 */

@objc(TiRootcheckModule)
class TiRootcheckModule: TiModule {

  public let testProperty: String = "Hello World"
  
  func moduleGUID() -> String {
    return "ba5aeb73-2468-4c54-ba69-8d7a01d9cc80"
  }
  
  override func moduleId() -> String! {
    return "ti.rootcheck"
  }

  @objc public var isRooted: Bool {
     get { 
       return UIDevice.current.isJailBroken
     }
   }
}
