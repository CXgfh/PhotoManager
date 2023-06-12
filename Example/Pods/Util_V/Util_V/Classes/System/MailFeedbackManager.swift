
import Foundation
import MessageUI

public class MailFeedbackManager: NSObject, MFMailComposeViewControllerDelegate {
    
    public override init() {
        super.init()
    }
    
    private var complete: (() -> Void)?
    
    public func openMail(from controller: UIViewController, recipient: [String], complete: (() -> Void)? = nil) {
        self.complete = complete
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: __("未设置邮箱账户"), message: __("要发送电子邮件，请设置电子邮件账户"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: __("确定"), style: .cancel))
            controller.present(alert, animated: true)
        } else {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            //设置主题行
            mail.setSubject(Util.appName)
            //设置收件人
            mail.setToRecipients(recipient)
            //设置信息初始内容
            let message = [
                "Device: \(Util.deviceVersion)",
                "App: \(Util.appName)",
                "Version: \(Util.appVersion)",
                "Country: \(Util.deviceCountry)",
                "Language: \(Util.appLanguage)",
            ]
            
            mail.setMessageBody(message.joined(separator: "\n") + "\n",isHTML: false)
            controller.present(mail, animated: true)
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: self.complete)
    }
}
