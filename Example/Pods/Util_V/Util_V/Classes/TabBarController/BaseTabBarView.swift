
import UIKit

public class BaseTabBarView: UITabBar {
    
    public private(set) var tabItems: [BaseTabBarItemView] = []
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        reloadContents()
    }
}


extension BaseTabBarView {
    func reloadItems(_ items: [BaseTabBarItemView]) {
        self.tabItems = items
        self.subviews.forEach{ $0.removeFromSuperview() }
        self.tabItems.forEach{ addSubview($0) }
        tabItems.first?.isSelected = true
    }
    
    private func reloadContents() {
        let itemW = frame.size.width / CGFloat(self.tabItems.count)
        var itemH: CGFloat
        if #available(iOS 11.0, *) {
            itemH = frame.size.height - (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0)
        } else {
            itemH = frame.size.height
        }
        
        for (index, tabItem) in self.tabItems.enumerated() {
            tabItem.frame = CGRect(x: CGFloat(index) * itemW, y: 0, width: itemW, height: itemH)
        }
    }
    
    func setCurrentIndex(_ tag: Int) {
        for (index, tabItem) in self.tabItems.enumerated() {
            tabItem.isSelected = index == tag
        }
    }
}
