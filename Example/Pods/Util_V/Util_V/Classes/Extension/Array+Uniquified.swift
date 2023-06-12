

import Foundation

public extension Array where Element: Equatable {
     var uniquified: [Element] {
        var elements = [Element]()
        forEach  { if !elements.contains($0) { elements.append($0) } }
        return elements
     }
}
