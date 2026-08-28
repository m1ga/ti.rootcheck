//
//  TiRootcheckModule.swift
//  ti.rootcheck
//
//  Created by Hans Knöchel
//  Copyright (c) 2022 Hans Knöchel. All rights reserved.
//

import UIKit
import TitaniumKit

@objc(TiRootcheckModule)
class TiRootcheckModule: TiModule {

  func moduleGUID() -> String {
    return "ba5aeb73-2468-4c54-ba69-8d7a01d9cc80"
  }

  override func moduleId() -> String! {
    return "ti.rootcheck"
  }

  /// `true` if the device appears to be jailbroken. Mirrors the `rooted` property of the Android module.
  @objc public var rooted: Bool {
    get {
      return UIDevice.current.isJailBroken
    }
  }
}
