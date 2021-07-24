//
//  CodeBaseWebViewController.swift
//  TSWebView_Example
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit
import WebKit
import SafariServices
import TSWebView

class CodeBaseWebViewController: UIViewController {
    private weak var webView: TSWebView!
    
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CodeBase"
        
        setUI()
        webView?.uiDelegate = self
        webView?.javaScriptEnable(target: self, protocol: JavaScriptInterface.self)
        if let urlString = urlString {
            webView.load(urlString: urlString)
        } else {
            webView.load(urlString: "https://tswebviewhosting.web.app")
        }
    }
}

// MARK: - Setup
private extension CodeBaseWebViewController {
    func setUI() {
        let webView = TSWebView()
        view.addSubview(webView)
        if let superview = webView.superview {
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
            webView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
            webView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
            webView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        }
        self.webView = webView
    }
}

// MARK: - JavaScriptInterface
extension CodeBaseWebViewController: JavaScriptInterface {
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
    
    func screenEvent(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let name = dictionary["name"] as? String
        else { return }
        let message = "name = \(name)"
        let alert = UIAlertController(title: "screenEvent", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
//        Analytics.logEvent(name, parameters: params)
    }
    
    func logEvent(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let name = dictionary["name"] as? String
//            let params = dictionary["parameters"] as? [String: NSObject]
        else { return }
//        let message = "name = \(name), parameters = \(params)"
        let message = "name = \(name)"
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

// MARK: - WKUIDelegate
extension CodeBaseWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Custom", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            completionHandler()
        }
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Custom", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}
