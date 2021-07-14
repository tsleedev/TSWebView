//
//  StoryboardWebViewController.swift
//  TSWebView
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit
import SafariServices
import TSWebView

class StoryboardWebViewController: UIViewController {
    @IBOutlet private weak var webView: TSWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storyboard"
        
        webView.javaScriptEnable(target: self, protocol: JavaScriptInterface.self)
        webView.load(urlString: "https://tswebviewhosting.web.app")
    }
}

// MARK: - JavaScriptInterface
extension StoryboardWebViewController: JavaScriptInterface {
    func openNewWebView(_ response: Any) {
        guard let dictionary = response as? [String: Any] else { return }
        let urlString: String?
        if let url = dictionary["url"] as? String {
            urlString = url
        } else if let path = dictionary["path"] as? String {
            urlString = "https://tswebviewhosting.web.app" + path
        } else {
            urlString = nil
            return
        }
        let destination = CodeBaseWebViewController()
        destination.urlString = urlString
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func closeWebView(_ response: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func goBack(_ response: Any) {
        if webView.canGoBack() {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func openExternalWebView(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let urlString = dictionary["url"] as? String,
            let url = URL(string: urlString)
        else { return }
        let destination = SFSafariViewController(url: url)
        present(destination, animated: true)
    }
    
    func outlink(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let urlString = dictionary["url"] as? String,
            let url = URL(string: urlString)
        else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func logEvent(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let name = dictionary["name"] as? String,
            let params = dictionary["parameters"] as? [String: NSObject]
        else { return }
        let message = "name = \(name), parameters = \(params)"
        let alert = UIAlertController(title: "logEvent", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
//        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserProperty(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let name = dictionary["name"] as? String,
            let value = dictionary["value"] as? String
        else { return }
        let message = "name = \(name), value = \(value)"
        let alert = UIAlertController(title: "setUserProperty", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
//        Analytics.setUserProperty(value, forName: name)
    }
}
