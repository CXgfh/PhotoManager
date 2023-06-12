//
//  DelegateCenter.swift
//  Vick_Custom
//
//  Created by Vick on 2022/8/9.
//

import Foundation

//NSArray、          NSDictionary、  NSSet
//NSPointerArray、   NSMapTable、    NSHashTable

open class DelegateCenter<T> {
    private var delegates = NSHashTable<AnyObject>(options: [.weakMemory, .objectPersonality])
    
    public func add(_ object: T) {
        delegates.add(object as AnyObject)
    }
    
    public func remove(_ object: T) {
        delegates.remove(object as AnyObject)
    }
    
    public func call(_ output: (T) -> ()) {
        delegates.allObjects.forEach { object in
            if let object = object as? T {
                output(object)
            }
        }
    }
    
    public init() { }
}
