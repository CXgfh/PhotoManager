//
//  Utilities.swift
//  asdasd
//
//  Created by flow on 2021/3/31.
//

import UIKit

public func LLog(_ items: Any...,
    file: String = #file,
    method: String = #function,
    line: Int = #line)
{
    #if DEBUG
    var output = ""
    for item in items {
        output += "\(item) "
    }
    output += "\n"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss:SSS"
    let timestamp = dateFormatter.string(from: Date())
    print("\(timestamp) | \((file as NSString).lastPathComponent)[\(line)] > \(method): ")
    print(output)
    #endif
}



