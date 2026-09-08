

import UIKit
import Toast_Swift

extension UIImageView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}
extension UIView {
    func applyBlurEffect1() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}

extension UIButton {
    func addBlurEffect(style: UIBlurEffect.Style = .regular, cornerRadius: CGFloat = 0, padding: CGFloat = 0) {
        backgroundColor = .clear
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        blurView.isUserInteractionEnabled = false
        blurView.backgroundColor = .clear
        if cornerRadius > 0 {
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
        }
        self.insertSubview(blurView, at: 0)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: padding).isActive = true
        self.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -padding).isActive = true
        self.topAnchor.constraint(equalTo: blurView.topAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: blurView.bottomAnchor, constant: -padding).isActive = true

        if let imageView = self.imageView {
            imageView.backgroundColor = .clear
            self.bringSubviewToFront(imageView)
        }
    }
}

extension UIViewController {
    func showAlert (title : String,message : String){
        let alert = UIAlertController(title: title, message:message , preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true,completion: nil)
    }

    func presentShareActivity(postUrl: String? = nil, text: String? = nil, sourceView: UIView? = nil) {
        var items: [Any] = []
        var validUrlString = (postUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !validUrlString.isEmpty {
            if !validUrlString.hasPrefix("http://") && !validUrlString.hasPrefix("https://") {
                validUrlString = "https://" + validUrlString
            }
            if let url = URL(string: validUrlString) {
                items.append(url)
            }
        }
        if items.isEmpty {
            if let text = text, !text.isEmpty {
                items.append(text)
            } else if !validUrlString.isEmpty {
                items.append(validUrlString)
            }
        }
        guard !items.isEmpty else { return }
        
        let shareContent = !validUrlString.isEmpty ? validUrlString : (text ?? "")
        let encodedContent = shareContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let anchorView = sourceView ?? self.view ?? UIView()
        
        let actionSheet = UIAlertController(title: NSLocalizedString("Share Post", comment: "Share Post"), message: nil, preferredStyle: .actionSheet)
        
        // 1. WhatsApp
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Share via WhatsApp", comment: "Share via WhatsApp"), style: .default, handler: { _ in
            let appUrl = URL(string: "whatsapp://send?text=\(encodedContent)")
            let webUrl = URL(string: "https://api.whatsapp.com/send?text=\(encodedContent)")
            if let app = appUrl, UIApplication.shared.canOpenURL(app) {
                UIApplication.shared.open(app, options: [:], completionHandler: nil)
            } else if let web = webUrl {
                UIApplication.shared.open(web, options: [:], completionHandler: nil)
            }
        }))
        
        // 2. Facebook
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Share via Facebook", comment: "Share via Facebook"), style: .default, handler: { _ in
            if let fbUrl = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(encodedContent)") {
                UIApplication.shared.open(fbUrl, options: [:], completionHandler: nil)
            }
        }))
        
        // 3. Twitter / X
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Share via X (Twitter)", comment: "Share via X (Twitter)"), style: .default, handler: { _ in
            let appUrl = URL(string: "twitter://post?message=\(encodedContent)")
            let webUrl = URL(string: "https://twitter.com/intent/tweet?url=\(encodedContent)")
            if let app = appUrl, UIApplication.shared.canOpenURL(app) {
                UIApplication.shared.open(app, options: [:], completionHandler: nil)
            } else if let web = webUrl {
                UIApplication.shared.open(web, options: [:], completionHandler: nil)
            }
        }))
        
        // 4. Copy Link
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Copy Link", comment: "Copy Link"), style: .default, handler: { [weak self] _ in
            UIPasteboard.general.string = shareContent
            self?.view.makeToast(NSLocalizedString("Link copied to clipboard", comment: "Link copied to clipboard"))
        }))
        
        // 5. System Share Sheet (More Options...)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("More Options...", comment: "More Options..."), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = anchorView
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: anchorView.bounds.midX, y: anchorView.bounds.midY, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = []
            self.present(activityViewController, animated: true, completion: nil)
        }))
        
        // 6. Cancel
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = anchorView
            popover.sourceRect = CGRect(x: anchorView.bounds.midX, y: anchorView.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }

}
extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}
extension Float {
    func toInt() -> Int? {
        if self > Float(Int.min) && self < Float(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
