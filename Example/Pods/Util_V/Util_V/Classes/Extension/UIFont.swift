

import UIKit

/*
 UIFont.familyNames
 let baseFont = UIFont(name: "American Typewriter", size: 20)!
 let boldFont = baseFont.bold
 let semibold = baseFont.semibold
 */
//MARK: - 指定自定义字体的字宽
public extension UIFont {
    var bold: UIFont { return withWeight(.bold) }
    
    var semibold: UIFont { return withWeight(.semibold) }
    
    var regular: UIFont { return withWeight(.regular) }

    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

public extension UIFont.Weight {
    func custom(name: String, size: CGFloat) -> UIFont? {
        return UIFont(name: name, size: size)?.withWeight(self)
    }
}
