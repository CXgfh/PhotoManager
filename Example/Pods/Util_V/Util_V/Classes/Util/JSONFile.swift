//
//  JSONFile.swift
//  Util_V
//
//  Created by V on 2023/4/17.
//

import UIKit

@propertyWrapper
public struct JSONFile<Value> {
    public var wrappedValue: Value
    private let url: URL?
    private let semaphore = DispatchSemaphore(value: 1)
    
    internal init(wrappedValue: Value, fileName: String) {
        let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName)
        self.init(wrappedValue: wrappedValue, url: url)
    }
    
    internal init(wrappedValue: Value, url: URL?) {
        self.wrappedValue = wrappedValue
        self.url = url
    }
}

public extension JSONFile where Value: Codable {
    init(defaultValue: Value, fileName: String) {
        let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName)
        if let url = url,
           let data = try? Data(contentsOf: url),
           let value = try? JSONDecoder().decode(Value.self, from: data) {
            self.init(wrappedValue: value, url: url)
            debugPrint("数据读取成功")
        } else {
            self.init(wrappedValue: defaultValue, url: url)
            debugPrint("数据读取失败")
        }
    }
    
    func save() {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
        if let data = try? JSONEncoder().encode(wrappedValue) {
            if let url = url {
                do {
                    try data.write(to: url)
                    debugPrint("数据存储成功")
                } catch {
                    debugPrint("数据存储失败")
                }
            } else {
                debugPrint("路径获取失败")
            }
        } else {
            debugPrint("JSON编码失败")
        }
    }
}
