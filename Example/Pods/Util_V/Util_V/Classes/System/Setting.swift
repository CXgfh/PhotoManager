//
//  Setting.swift
//  VSystem
//
//  Created by Vick on 2022/9/22.
//

import UIKit


public func openSettings(parent: UIViewController,
                         title: String?,
                         message: String?,
                         cancel: String,
                         confirm: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title:  cancel, style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: confirm, style: .default, handler: { (_) in
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }))
    findTopViewController(parent)?.present(alert, animated: true)
}

public func appReview(_ appID: String) {
    if let url =  "https://itunes.apple.com/us/app/id\(appID)?action=write-review".url {
        UIApplication.shared.open(url)
    }
}

public func appUpdate(_ appID: String) {
    if let url = "https://itunes.apple.com/us/app/id\(appID)".url {
        UIApplication.shared.open(url)
    }
}

public func appShare(_ appID: String,
                     _ view: UIView,
                     _ complet: UIActivityViewController.CompletionWithItemsHandler?) {
    if let url = "https://apps.apple.com/cn/app/id\(appID)".url {
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: [])
        activityController.completionWithItemsHandler = complet
        view.viewController?.present(activityController, animated: true)
        if let popOver = activityController.popoverPresentationController {
            popOver.sourceView = view
        }
    }
}
