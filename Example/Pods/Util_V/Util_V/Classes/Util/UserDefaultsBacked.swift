//
//  UserDefaultsBacked.swift
//  Util_V
//
//  Created by V on 2023/3/22.
//

import Foundation

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

@propertyWrapper
public struct UserDefaultsBacked<Value> {
    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.setValue(newValue, forKey: key)
            }
        }
    }
    
    private let key: String
    private let defaultValue: Value
    private let storage: UserDefaults
    
    public init(wrappedValue defaultValue: Value ,key: String, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
}

//ExpressibleByNilLiteral: 一种可以使用nil文字初始化的类型
extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    public init(key: String, storage: UserDefaults = .standard) {
        self.init(wrappedValue: nil, key: key, storage: storage)
    }
}

