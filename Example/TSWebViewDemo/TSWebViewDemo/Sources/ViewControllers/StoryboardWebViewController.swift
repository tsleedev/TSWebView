//
//  StoryboardWebViewController.swift
//  TSWebViewDemo
//
//  Created by TAE SU LEE on 2021/07/08.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import TSWebView
import UIKit
import WebKit
import SafariServices

class StoryboardWebViewController: UIViewController {
    @IBOutlet private weak var webView: TSWebView!
    private var jsHandler: JavaScriptHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storyboard"
        
        webView.uiDelegate = self
        let jsHandler = JavaScriptHandler(viewController: self, webView: webView)
        webView.javaScriptEnable(target: jsHandler, protocol: JavaScriptInterface.self)
        self.jsHandler = jsHandler
        webView.load(urlString: "https://tswebviewhosting.web.app")
    }
}

// MARK: - WKUIDelegate
extension StoryboardWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
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
