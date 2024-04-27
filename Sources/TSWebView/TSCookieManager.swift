//
//  TSCookieManager.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit
import WebKit

class TSCookieManager: NSObject, TSCookieType {
    static let shared = TSCookieManager()
    
    private var baseURL: URL?
    private var appendUserAgent: String = ""
    
    private var processPool = WKProcessPool()
    private let cookieWindow = UIWindow(frame: CGRect.zero)
    private var webView: WKWebView!
    
    func prepare(baseURL: URL?, appendUserAgent: String) {
        self.baseURL = baseURL
        self.appendUserAgent = appendUserAgent
        
//        cookieWindow.windowLevel = UIWindow.Level(rawValue: -1)
        if webView != nil {
            webView.removeFromSuperview()
            webView = nil
        }
        webView = createWKWebView(CGRect.zero)
        cookieWindow.addSubview(webView)
        webView.loadHTMLString("", baseURL: baseURL)
    }
    
    func createWKWebView(_ frame: CGRect) -> WKWebView {
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = appendUserAgent
        let userContentController: WKUserContentController = WKUserContentController()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes(rawValue: 0)
        configuration.processPool = processPool
        
        return WKWebView(frame: frame, configuration: configuration)
    }
    
    func userAgent(completionHandler: ((String?) -> Void)? = nil) {
        webView.evaluateJavaScript("navigator.userAgent") { userAgent, _ in
            completionHandler?(userAgent as? String)
            // iOS 8.3
            // Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12F70
            // iOS 9.0
            // Mozilla/5.0 (iPhone; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.32 (KHTML, like Gecko) Mobile/13A4254v
        }
    }
}

// MARK: - Private (Web)
private extension TSCookieManager {
    func _syncWebCookie(cookie: HTTPCookie, completionHandler: (() -> Void)? = nil) {
        if webView.isLoading { // 0.1초 후 재시도
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                self?._syncWebCookie(cookie: cookie, completionHandler: completionHandler)
            }
            return
        }
        
        webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
            completionHandler?()
        }
    }
    
    func _deleteWebCookie(cookies: [HTTPCookie]?, completionHandler: (() -> Void)? = nil) {
        guard let cookies = cookies else {
            completionHandler?()
            return
        }
        
        if webView.isLoading { // 0.1초 후 재시도
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                self?._deleteWebCookie(cookies: cookies, completionHandler: completionHandler)
            }
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        cookies.forEach { cookie in
            dispatchGroup.enter()
            webView.configuration.websiteDataStore.httpCookieStore.delete(cookie) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler?()
        }
    }
    
    func _getAllWebCookies(completionHandler: @escaping (([HTTPCookie]?) -> Void)) {
        if webView.isLoading { // 0.1초 후 재시도
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                self?._getAllWebCookies(completionHandler: completionHandler)
            }
            return
        }
        
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { allCookies in
            completionHandler(allCookies)
        }
    }
}

// MARK: - Public (Web)
extension TSCookieManager {
    func webCookie(name: String, completionHandler: @escaping (([HTTPCookie]?) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            self?.allWebCookies { [weak self] cookies in
                completionHandler(self?.findCookie(name: name, cookies: cookies))
            }
        }
    }
    
    func allWebCookies(completionHandler: @escaping (([HTTPCookie]?) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            self?._getAllWebCookies(completionHandler: completionHandler)
        }
    }
    
    @objc func syncWebCookie(_ cookie: HTTPCookie, onlyName: String? = nil, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let onlyName = onlyName, cookie.name != onlyName {
                completionHandler?()
                return
            }
            self?._syncWebCookie(cookie: cookie, completionHandler: completionHandler)
        }
    }
    
    func syncWebCookies(_ cookies: [HTTPCookie], onlyName: String? = nil, completionHandler: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        cookies.forEach { [weak self] cookie in
            dispatchGroup.enter()
            self?.syncWebCookie(cookie, onlyName: onlyName) {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler?()
        }
    }
    
    func deleteWebCookie(_ name: String, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.webCookie(name: name) { [weak self] cookies in
                self?._deleteWebCookie(cookies: cookies, completionHandler: completionHandler)
            }
        }
    }
}

// MARK: - Public (API)
extension TSCookieManager {
    func apiCookie(name: String, completionHandler: @escaping (([HTTPCookie]?) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            self?.allApiCookies { [weak self] cookies in
                completionHandler(self?.findCookie(name: name, cookies: cookies))
            }
        }
    }
    
    func allApiCookies(completionHandler: @escaping (([HTTPCookie]?) -> Void)) {
        DispatchQueue.main.async {
            completionHandler(HTTPCookieStorage.shared.cookies)
        }
    }
    
    func syncApiCookie(_ cookie: HTTPCookie, onlyName: String? = nil, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let onlyName = onlyName, cookie.name != onlyName {
                completionHandler?()
                return
            }
            self?.deleteApiCookie(cookie.name) {
                HTTPCookieStorage.shared.setCookie(cookie)
                completionHandler?()
            }
        }
    }
    
    func syncApiCookies(_ cookies: [HTTPCookie], onlyName: String? = nil, completionHandler: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        cookies.forEach { [weak self] cookie in
            dispatchGroup.enter()
            self?.syncApiCookie(cookie, onlyName: onlyName) {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler?()
        }
    }
    
    func deleteApiCookie(_ name: String, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.apiCookie(name: name) { cookies in
                if let cookies = cookies {
                    cookies.forEach { cookie in
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }
                }
                completionHandler?()
            }
        }
    }
}

// MARK: - Public (Common)
extension TSCookieManager {
    func syncCookie(_ cookie: HTTPCookie, completionHandler: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        syncApiCookie(cookie) {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        syncWebCookie(cookie) {
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler?()
        }
    }
    
    func syncCookies(_ cookies: [HTTPCookie], completionHandler: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        syncApiCookies(cookies) {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        syncWebCookies(cookies) {
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler?()
        }
    }
    
    func deleteCookie(_ name: String, completionHandler: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        deleteApiCookie(name) {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        deleteWebCookie(name) {
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler?()
        }
    }
}
