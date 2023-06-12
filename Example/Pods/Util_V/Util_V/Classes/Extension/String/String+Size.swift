

import UIKit


//MARK: -文本属性
public extension String {
    ///指定font，计算单行文本宽度
     func stringWidth(font: UIFont = UIFont.systemFont(ofSize: 14, weight: .semibold)) -> CGFloat {
        return self.size(font: font).width
    }
    
    ///指定font，计算单行文本size
    func size(font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [.font : font])
    }
    
    ///指定font，计算多行文本size, 或通过 UILabel.textRect计算
    func size(drawIn size: CGSize, font: UIFont, options: NSStringDrawingOptions = .usesLineFragmentOrigin, lineBreak: NSLineBreakMode = .byCharWrapping) -> CGSize {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = lineBreak
        let dic = [NSAttributedString.Key.font: font, .paragraphStyle: paragraph]
        let bounds = NSAttributedString(string: self, attributes: dic).boundingRect(with: size, options: options, context: nil)
        return bounds.size
    }
    
    ///指定size，计算文本font
    func getFontSize(font: UIFont, frame: CGSize, minimumScaleFactor: CGFloat = 0.1) -> CGFloat {
        let attributed = NSMutableAttributedString(attributedString: NSAttributedString(string: self, attributes: [.font: font]))
        let context = NSStringDrawingContext()
        context.minimumScaleFactor = minimumScaleFactor
        attributed.boundingRect(with: frame, options: .usesLineFragmentOrigin, context: context)
        return font.pointSize * context.actualScaleFactor
    }
}



