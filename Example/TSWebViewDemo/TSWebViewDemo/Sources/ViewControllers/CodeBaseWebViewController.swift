//
//  CodeBaseWebViewController.swift
//  TSWebViewDemo
//
//  Created by TAE SU LEE on 2021/07/08.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit
import WebKit
import TSWebView

class CodeBaseWebViewController: UIViewController {
    private let webView = TSWebView()
    
    var urlString: String?
    private var jsHandler: JavaScriptHandler?
    
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
        let jsHandler = JavaScriptHandler(viewController: self, webView: webView)
        webView.javaScriptEnable(target: jsHandler, protocol: JavaScriptInterface.self)
        self.jsHandler = jsHandler
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
