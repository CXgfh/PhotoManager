//
//  Util+Device.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import UIKit
import LocalAuthentication

//MARK: -设备信息
public extension Util {
    ///主windows状态栏高度
    static var deviceStatusHeight: CGFloat {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first{ $0.isKeyWindow }?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    ///安全区
    static var deviceSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, tvOS 11.0, *) {
            if let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets {
                return safeAreaInsets
            }
        }
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    /// 设备是否已登记Touch ID（打开了Passcode 且 设置了Touch ID）
    static var deviceCanUseTouchID: Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    ///是否是iPad
    static var deviceIsIPad: Bool {
        if #available(iOS 13.0, *) {
            return UIDevice.current.userInterfaceIdiom == .pad
        } else {
            return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
        }
    }
    
    static var deviceIsIPhone: Bool {
        if #available(iOS 13.0, *) {
            return UIDevice.current.userInterfaceIdiom == .phone
        } else {
            return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
        }
    }
    
    /// 是否横屏
    @available(iOSApplicationExtension, unavailable)
    static var deviceIsLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
    
    ///是否是模拟器
    static var deviceIsSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    /// 原始设备型号
    static var deviceModel: String {
        if deviceIsSimulator {
            //模拟器模型标识符
            return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"
        }
        var systemInfo = utsname()
        uname(&systemInfo)
        
        if let utf8String = NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)?.utf8String {
            if let versionCode = String(validatingUTF8: utf8String) {
                return versionCode
            }
        }
        
        return "unknown"
    }
    
    /// 返回精确设备型号
    static var deviceVersion: String {
        var deviceName = "unknown"
        
        if deviceModel.contains("iPhone") {
            deviceName = "iPhone"
        } else if deviceModel.contains("iPad") {
            deviceName = "iPad"
        } else if deviceModel.contains("iPod") {
            deviceName = "iPod"
        }
        
        switch deviceModel {
//MARK:  ----- iPhone  ---
        case "iPhone7,2":                                deviceName = "iPhone 6"
        case "iPhone7,1":                                deviceName = "iPhone 6 Plus"
        case "iPhone8,1":                                deviceName = "iPhone 6S"
        case "iPhone8,2":                                deviceName = "iPhone 6S Plus"
        case "iPhone8,3", "iPhone8,4":                   deviceName = "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                   deviceName = "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                   deviceName = "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                 deviceName = "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                 deviceName = "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                 deviceName = "iPhone X"
        case "iPhone11,2":                               deviceName = "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                 deviceName = "iPhone XS Max"
        case "iPhone11,8":                               deviceName = "iPhone XR"
        case "iPhone12,1":                               deviceName = "iPhone 11"
        case "iPhone12,3":                               deviceName = "iPhone 11 Pro"
        case "iPhone12,5":                               deviceName = "iPhone 11 Pro Max"
        case "iPhone12,8":                               deviceName = "iPhone SE 2"
        case "iPhone13,1":                               deviceName = "iPhone 12 mini"
        case "iPhone13,2":                               deviceName = "iPhone 12"
        case "iPhone13,3":                               deviceName = "iPhone 12 Pro"
        case "iPhone13,4":                               deviceName = "iPhone 12 Pro Max"
        case "iPhone14,4":                               deviceName = "iPhone 13 mini"
        case "iPhone14,5":                               deviceName = "iPhone 13"
        case "iPhone14,2":                               deviceName = "iPhone 13 Pro"
        case "iPhone14,3":                               deviceName = "iPhone 13 Pro Max"
        case "iPhone14,6":                               deviceName = "iPhone SE 3"
        case "iPhone14,7":                               deviceName = "iPhone 14"
        case "iPhone14,8":                               deviceName = "iPhone 14 Plus"
        case "iPhone15,2":                               deviceName = "iPhone 14 Pro"
        case "iPhone15,3":                               deviceName = "iPhone 14 Pro Max"

//MARK: ------- iPad ------
        case "iPad1,1", "iPad1,2":                       deviceName = "iPad 1"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": deviceName = "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":            deviceName = "iPad mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":            deviceName = "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":            deviceName = "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":            deviceName = "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":            deviceName = "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":            deviceName = "iPad mini 3"
        case "iPad5,1", "iPad5,2":                       deviceName = "iPad mini 4"
        case "iPad5,3", "iPad5,4":                       deviceName = "iPad Air2"
        case "iPad6,3", "iPad6,4":                       deviceName = "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8":
            deviceName = "iPad Pro (12.9-inch)"
        case "iPad6,11", "iPad6,12":                     deviceName = "iPad 5"
        case "iPad7,1", "iPad7,2":
            deviceName = "iPad Pro 2 (12.9-inch)"
        case "iPad7,3", "iPad7,4":                       deviceName = "iPad Pro (10.5-inch)"
        case "iPad7,5", "iPad 7,6":                      deviceName = "iPad 6"
        case "iPad7,11", "iPad 7,12":                      deviceName = "iPad 7"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":
            deviceName = "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
            deviceName = "iPad Pro 3 (12.9-inch)"
        case "iPad8,9", "iPad8,10":
            deviceName = "iPad Pro 2 (11-inch)"
        case "iPad8,11", "iPad8,12":
            deviceName = "iPad Pro 4 (12.9-inch)"
        case "iPad11,1", "iPad11,2":
            deviceName = "iPad mini 5"
        case "iPad11,3", "iPad11,4":
            deviceName = "iPad Ari 3"
        case "iPad11,6", "iPad11,7":
            deviceName = "iPad 8"
        case "iPad12,1", "iPad12,2":
            deviceName = "iPad 9"
        case "iPad13,1", "iPad13,2":
            deviceName = "iPad Ari 4"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":
            deviceName = "iPad Pro 4 (11-inch)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":
            deviceName = "iPad Pro 5 (12.9-inch)"
        case "iPad14,1", "iPad14,2":
            deviceName = "iPad mini 6"
            
//MARK: ------ iPod --------
        case "iPod1,1":                                  deviceName = "iPod Touch 1"
        case "iPod2,1":                                  deviceName = "iPod Touch 2"
        case "iPod3,1":                                  deviceName = "iPod Touch 3"
        case "iPod4,1":                                  deviceName = "iPod Touch 4"
        case "iPod5,1":                                  deviceName = "iPod Touch 5"
        case "iPod7,1":                                  deviceName = "iPod Touch 6"
        case "iPod9,1":                                  deviceName = "iPod Touch 7"
            
// MARK : ----- Simulator --------
        case "i386", "x86_64":                           deviceName = "simulator"
        default: break
        }
        
        return deviceName
    }
    
    ///地区
    static var deviceCountry: String {
        return NSLocale.current.regionCode ?? ""
    }
    
    ///系统版本
    static var deviceSystemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    ///手机标识
    static var deviceUUID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    ///ip地址
    static var deviceIP: String {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first ?? "0.0.0.0"
    }

    ///存储总容量
    static var deviceTotalDisk: Int64 {
        let message = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return (message?[.systemSize] as? NSNumber)?.int64Value ?? 0
    }
    
    ///存储剩余容量
    static var deviceFreeDisk: Int64 {
        let message = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return (message?[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
    }
}
