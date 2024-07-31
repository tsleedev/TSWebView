//
//  CodeBaseWebViewController.swift
//  TSWebView_Example
//
//  Created by TAE SU LEE on 2021/07/08.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import TSWebView

class CodeBaseWebViewController: UIViewController {
    private let webView = TSWebView()
    
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CodeBase"
        
        setupViews()
        setupConstraints()
        configureUI()
        
        if let urlString = urlString {
            webView.load(urlString: urlString)
        } else {
            webView.load(urlString: "https://tswebviewhosting.web.app")
        }
    }
}

// MARK: - Setup
private extension CodeBaseWebViewController {
    /// Initialize and add subviews
    func setupViews() {
        view.addSubview(webView)
        webView.uiDelegate = self
        webView.javaScriptEnable(target: self, protocol: JavaScriptInterface.self)
    }
    
    /// Set up Auto Layout constraints
    func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// Initialize UI elements and localization
    func configureUI() {
        view.backgroundColor = .systemBackground
    }
}

// MARK: - JavaScriptInterface
extension CodeBaseWebViewController: JavaScriptInterface {
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
//            let params = dictionary["parameters"] as? [String: Any]
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
    
    func openPhoneSettings(_ response: Any) {
        guard let dictionary = response as? [String: Any] else { return }
        
        guard let setting = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(setting)
                
        guard let callback = dictionary["callbackId"] as? String else { return }
        let script = "\(callback)();"
        webView.evaluateJavaScript(script, completion: nil)
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
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return nil
        }
        completionHandler(configuration)
    }
}
