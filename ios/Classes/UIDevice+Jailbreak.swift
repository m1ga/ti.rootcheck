//
//  UIDevice+Jailbreak.swift
//  TiRootcheck
//
//  Created by Hans Knöchel on 11.11.22.
//

import UIKit
import Foundation
import MachO
import TitaniumKit

extension UIDevice {
  var isSimulator: Bool {
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
  }

  /// Heuristic jailbreak detection. Covers classic (rootful) jailbreaks as well as
  /// modern rootless ones (Dopamine, palera1n, ...) that live under `/var/jb`.
  var isJailBroken: Bool {
    if isSimulator { return false }

    return JailBrokenHelper.hasSuspiciousFiles()
      || JailBrokenHelper.hasSuspiciousDylibs()
      || JailBrokenHelper.hasSuspiciousEnvironment()
      || JailBrokenHelper.canWriteOutsideSandbox()
      || JailBrokenHelper.canFork()
      || JailBrokenHelper.hasSuspiciousURLSchemes()
  }
}

private struct JailBrokenHelper {

  // MARK: - URL schemes

  /// Checks whether a package manager registered one of its URL schemes.
  ///
  /// NOTE: `canOpenURL` only works for schemes that are listed in the app's
  /// `LSApplicationQueriesSchemes` (tiapp.xml). Otherwise it always returns `false`.
  static func hasSuspiciousURLSchemes() -> Bool {
    let check: () -> Bool = {
      for scheme in suspiciousURLSchemes {
        if let url = URL(string: "\(scheme)://package/com.example.package"), UIApplication.shared.canOpenURL(url) {
          return true
        }
      }
      return false
    }

    if Thread.isMainThread {
      return check()
    }

    // UIApplication must be accessed on the main thread; property getters are invoked on the JS thread.
    var result = false
    TiThreadPerformOnMainThread({ result = check() }, true)
    return result
  }

  // MARK: - Files

  static func hasSuspiciousFiles() -> Bool {
    for path in suspiciousPaths {
      if fileExists(path) {
        return true
      }
    }
    return false
  }

  /// Uses both Foundation and a raw `stat()` call, as tweaks that try to hide a
  /// jailbreak usually only hook the Foundation API.
  private static func fileExists(_ path: String) -> Bool {
    if FileManager.default.fileExists(atPath: path) {
      return true
    }

    var info = stat()
    return stat(path, &info) == 0
  }

  // MARK: - Loaded libraries

  /// Checks the loaded images for well-known tweak injection / hooking frameworks.
  static func hasSuspiciousDylibs() -> Bool {
    let count = _dyld_image_count()
    for i in 0..<count {
      guard let cName = _dyld_get_image_name(i) else { continue }
      let name = String(cString: cName).lowercased()
      for needle in suspiciousLibraries where name.contains(needle) {
        return true
      }
    }
    return false
  }

  // MARK: - Environment

  static func hasSuspiciousEnvironment() -> Bool {
    if let value = getenv("DYLD_INSERT_LIBRARIES"), strlen(value) > 0 {
      return true
    }
    return false
  }

  // MARK: - Sandbox

  /// A sandboxed app must not be able to write outside of its container.
  static func canWriteOutsideSandbox() -> Bool {
    let paths = ["/private/jailbreak.txt", "/var/jb/jailbreak.txt"]

    for path in paths {
      do {
        try "jailbreak".write(toFile: path, atomically: true, encoding: .utf8)
        try? FileManager.default.removeItem(atPath: path)
        return true
      } catch {
        continue
      }
    }
    return false
  }

  /// `fork()` is denied by the sandbox on a non-jailbroken device.
  static func canFork() -> Bool {
    // `fork` is marked unavailable in Swift on iOS, so resolve it dynamically.
    let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)
    guard let forkSymbol = dlsym(rtldDefault, "fork") else { return false }

    typealias ForkFunction = @convention(c) () -> Int32
    let fork = unsafeBitCast(forkSymbol, to: ForkFunction.self)
    let pid = fork()

    if pid < 0 {
      return false
    }

    if pid == 0 {
      // Child process: terminate immediately.
      exit(0)
    }

    var status: Int32 = 0
    waitpid(pid, &status, 0)
    return true
  }

  // MARK: - Lists

  static let suspiciousURLSchemes = ["cydia", "sileo", "zbra", "undecimus", "filza"]

  static let suspiciousLibraries = [
    "mobilesubstrate",
    "substrateloader",
    "substrateinserter",
    "cydiasubstrate",
    "substitute",
    "libhooker",
    "tweakinject",
    "tweakloader",
    "cynject",
    "cycript",
    "frida",
    "libjailbreak",
    "sslkillswitch"
  ]

  /// Paths of classic (rootful) jailbreaks. Every entry is also checked with the
  /// rootless `/var/jb` prefix.
  private static let rootfulPaths = [
    // Package managers / apps
    "/Applications/Cydia.app",
    "/Applications/Sileo.app",
    "/Applications/Zebra.app",
    "/Applications/Installer.app",
    "/Applications/Filza.app",
    "/Applications/blackra1n.app",
    "/Applications/FakeCarrier.app",
    "/Applications/Icy.app",
    "/Applications/IntelliScreen.app",
    "/Applications/MxTube.app",
    "/Applications/RockApp.app",
    "/Applications/SBSettings.app",
    "/Applications/WinterBoard.app",

    // Tweak injection
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/Library/MobileSubstrate/DynamicLibraries",
    "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
    "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
    "/usr/lib/libsubstrate.dylib",
    "/usr/lib/substrate",
    "/usr/lib/libsubstitute.dylib",
    "/usr/lib/substitute",
    "/usr/lib/libhooker.dylib",
    "/usr/lib/TweakInject",
    "/usr/lib/libjailbreak.dylib",
    "/usr/lib/libcycript.dylib",

    // Daemons
    "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
    "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
    "/Library/LaunchDaemons/com.openssh.sshd.plist",

    // Unix userland
    "/bin/bash",
    "/usr/sbin/sshd",
    "/usr/bin/sshd",
    "/usr/bin/ssh",
    "/usr/libexec/sftp-server",
    "/usr/libexec/ssh-keysign",
    "/etc/apt",
    "/etc/ssh/sshd_config",
    "/private/var/lib/apt",
    "/private/var/lib/cydia",
    "/private/var/cache/apt",
    "/private/var/stash",
    "/private/var/tmp/cydia.log",
    "/private/var/log/syslog",
    "/private/var/mobile/Library/SBSettings/Themes",

    // Jailbreak tool markers
    "/var/binpack",
    "/var/checkra1n.dmg",
    "/private/var/checkra1n.dmg",
    "/.installed_unc0ver",
    "/.bootstrapped_electra",
    "/private/etc/apt/undecimus",
    "/private/etc/apt/sources.list.d/electra.list",
    "/private/etc/apt/sources.list.d/sileo.sources",
    "/etc/apt/sources.list.d/sileo.sources",
    "/etc/apt/sources.list.d/procursus.sources"
  ]

  static let suspiciousPaths: [String] = {
    var paths = rootfulPaths
    // Rootless jailbreaks (Dopamine, palera1n rootless, XinaA15, ...) keep everything under /var/jb.
    paths.append("/var/jb")
    paths.append("/private/var/jb")
    paths.append("/var/jb/.installed_dopamine")
    paths.append("/var/jb/.procursus_strapped")
    paths.append(contentsOf: rootfulPaths.map { "/var/jb" + $0 })
    return paths
  }()
}
