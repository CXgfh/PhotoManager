
import Foundation


public extension Thread {
    
    class func safeSync(execute work: @escaping () -> Void) {
        if isMainThread {
            work()
        }
        else {
            DispatchQueue.main.sync {
                work()
            }
        }
    }
    
    class func safeAsync(execute work: @escaping () -> Void) {
        if isMainThread {
            work()
        }
        else {
            DispatchQueue.main.async {
                work()
            }
        }
    }
    
}
