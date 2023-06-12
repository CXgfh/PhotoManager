//
//  Util+Configuration.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
public class Util {
    public init() { }
}

//MARK: -获取项目配置信息
public extension Util {
    ///返回本地化的app名称
    static var appName: String {
        if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        } else if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        } else {
            return Bundle.main.infoDictionary?["CFBundleName"] as! String
        }
    }
    
    ///logo
    static var appLogo: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
    ///返回版本号
    static var appVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    ///能否更新版本
    static func canUpdateVersion(new version: String) -> Bool {
        let nowArray = appVersion.split(separator: ".")
        let newArray = version.split(separator: ".")
        let big = nowArray.count > newArray.count ? newArray.count : nowArray.count
        for index in 0..<big {
            let first = nowArray[index]
            let second = newArray[index]
            if Int(first)! < Int(second)!  {
                return true
            }
        }
        return false
    }
    
    /// 返回构建号
    static var appBuildVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
    }
    
    ///语言
    static var appLanguage: String {
        if let language = objc_getAssociatedObject(Bundle.main, &languageKey) as? String {
            return language
        } else {
            return Bundle.main.preferredLocalizations.first ?? ""
        }
    }
    
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
}
