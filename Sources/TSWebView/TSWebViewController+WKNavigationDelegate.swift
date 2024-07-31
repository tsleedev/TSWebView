//
//  TSWebViewController+WKNavigationDelegate.swift
//  TSFramework
//
//  Created by TAE SU LEE on 7/30/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit
import WebKit

// MARK: - WKNavigationDelegate
extension TSWebViewController: WKNavigationDelegate {
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme, !scheme.isEmpty
        else { return .cancel }
        
        let validSchemes: Set<String> = ["http", "https", "about"]
        
        if !validSchemes.contains(scheme) {
            if UIApplication.shared.canOpenURL(url) {
                await UIApplication.shared.open(url)
            } else {
                let etcSchemes: Set<String> = ["tel", "mailto"]
                if etcSchemes.contains(scheme) {
                    await UIApplication.shared.open(url)
                }
            }
            return .cancel
        }
        
        return .allow
    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showRetryView()
    }
    
    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showRetryView()
    }
}
