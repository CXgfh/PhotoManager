

import UIKit

open class BaseTabBarViewController: UITabBarController {
    
    public private(set) lazy var customTabBar = BaseTabBarView(frame: self.tabBar.frame)
    
    public override var selectedIndex: Int {
        didSet {
            self.customTabBar.setCurrentIndex(selectedIndex)
        }
    }
    
    public init(controllers: [UIViewController], tabItems: [BaseTabBarItemView]) {
        super.init(nibName: nil, bundle: nil)
        controllers.forEach { $0.hidesBottomBarWhenPushed = false }
        viewControllers = controllers
        customTabBar.reloadItems(tabItems)
        customTabBar.backgroundColor = .white
        setValue(customTabBar, forKey: "tabBar")
        delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BaseTabBarViewController {
    public func setCornerMark(_ number: Int, at index: Int) {
        customTabBar.tabItems[index].cornerMark = index
    }
}

extension BaseTabBarViewController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let tabbar = tabBarController as? BaseTabBarViewController else {
            return
        }
        tabbar.selectedIndex = tabBarController.selectedIndex
    }
}
