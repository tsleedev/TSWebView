//
//  TSWebViewController+WKUIDelegate.swift
//  TSFramework
//
//  Created by TAE SU LEE on 7/30/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

// MARK: - WKUIDelegate
extension TSWebViewController: WKUIDelegate {
    open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    open func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
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
    
    open func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil,
              let currentURL = webView.url,
              let newURL = navigationAction.request.url
        else { return nil }
        
        if let currentHost = currentURL.host,
           let newHost = newURL.host,
           currentHost == newHost {
            let webView = TSWebView(frame: .zero, configuration: configuration)
            let viewController = createWebViewController(webView: webView)
            navigationController?.pushViewController(viewController, animated: true)
            return webView
        } else {
            let viewController = SFSafariViewController(url: newURL)
            present(viewController, animated: true)
        }
        
        return nil
    }
    
    open func webViewDidClose(_ webView: WKWebView) {
        guard var viewControllers = navigationController?.viewControllers,
              let index = viewControllers.firstIndex(where: { $0 == self })
        else { return }
        viewControllers.remove(at: index)
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    open func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return nil
        }
        completionHandler(configuration)
    }
}
