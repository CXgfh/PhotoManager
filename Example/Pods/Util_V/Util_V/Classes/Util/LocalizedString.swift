//
//  LocalizedMaker.swift
//  Social Maker
//
//  Created by Frank on 2021/6/15.
//

import Foundation

private var bundleKey: UInt8 = 0

internal var languageKey: UInt8 = 0

public class AnyLanguageBundle: Bundle {

    public override func localizedString(forKey key: String,
                                         value: String?,
                                         table tableName: String?) -> String {

        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

public func __(_ text: String) -> String {
    return NSLocalizedString(text, tableName: "Localizable", bundle: Bundle.main, value: "", comment: "")
}

public extension Bundle {

    class func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }

        if let path = Bundle.main.path(forResource: language, ofType:"lproj"),
            Bundle(path: path) != nil {
            
            objc_setAssociatedObject(Bundle.main, &bundleKey, path, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            objc_setAssociatedObject(Bundle.main, &languageKey, language, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            fatalError("没有创建本地化文件")
        }
    }
}
