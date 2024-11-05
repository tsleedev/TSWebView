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
import SafariServices

class OpenSourceWebViewController: TSWebViewController {
    private var startURL: String?
    private var jsHandler: JavaScriptHandler?
    
    init(webView: TSWebView, startURL: String?) {
        super.init(webView: webView)
        self.startURL = startURL
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.startURL = "https://tswebviewhosting.web.app"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.allowsBackForwardNavigationGestures = true
        
        if let startURL = startURL {
            webView.load(urlString: startURL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        let jsHandler = JavaScriptHandler(viewController: self, webView: webView)
        webView.javaScriptEnable(target: jsHandler, protocol: JavaScriptInterface.self)
        self.jsHandler = jsHandler
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForAppStateNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterForAppStateNotifications()
    }
    
    override func createWebViewController(webView: TSWebView) -> TSWebViewController {
        return OpenSourceWebViewController(webView: webView, startURL: nil)
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

// MARK: - TSWebViewDelegate
extension OpenSourceWebViewController: TSWebViewDelegate {
    func configureWebView(for newWebView: TSWebView, with newURL: URL) -> Bool {
        guard let currentURL = self.webView.url else { return false }
        
        // host가 동일한지 확인
        if let currentHost = currentURL.host, let newHost = newURL.host, currentHost == newHost {
            // URL에 appmode=modal이 있는지 확인
            let urlComponents = URLComponents(url: newURL, resolvingAgainstBaseURL: false)
            let isModal = urlComponents?.queryItems?.contains(where: { $0.name == "appmode" && $0.value == "modal" }) ?? false
            
            if isModal {
                let viewController = OpenSourceWebViewController(webView: newWebView, startURL: nil)
                let navigationController = UINavigationController(rootViewController: viewController)
                navigationController.modalPresentationStyle = .fullScreen
                present(navigationController, animated: true)
                return true
            }
        }
        return false
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
