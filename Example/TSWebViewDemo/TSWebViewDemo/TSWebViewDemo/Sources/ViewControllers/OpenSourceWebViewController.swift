//
//  OpenSourceWebViewController.swift
//  TSWebViewDemo
//
//  Created by TAE SU LEE on 7/30/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import TSWebView
import UIKit
import WebKit

class OpenSourceWebViewController: TSWebViewController {
    private var startURL: String?
    
    convenience init(webView: TSWebView, startURL: String) {
        self.init(webView: webView)
        self.startURL = startURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForAppStateNotifications()
        webView.javaScriptEnable(target: self, protocol: JavaScriptInterface.self)
        
        if let startURL = startURL {
            webView.load(urlString: startURL)
        }
    }
    
    deinit {
        unregisterForAppStateNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func createWebViewController(webView: TSWebView) -> TSWebViewController {
        return OpenSourceWebViewController(webView: webView)
    }
    
    override func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler()
        }
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
}

// MARK: - Notification
extension OpenSourceWebViewController {
    func registerForAppStateNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func unregisterForAppStateNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground() {
        webView.evaluateJavaScript("onAppBackground()", completion: nil)
    }
    
    @objc func applicationWillEnterForeground() {
        webView.evaluateJavaScript("onAppForeground()", completion: nil)
    }
}

// MARK: - JavaScriptInterface
extension OpenSourceWebViewController: JavaScriptInterface {
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
