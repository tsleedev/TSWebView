//
//  TSWebView.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit
import WebKit

public class TSWebView: UIView {
    var scrollView: UIScrollView {
        return webView.scrollView
    }
    
    var customUserAgent: String? {
        get {
            return webView.customUserAgent
        }
        set {
            webView.customUserAgent = newValue
        }
    }
    
    var url: URL? {
        return webView.url
    }
    
    var host: String? {
        return webView.url?.host
    }
    
    var path: String? {
        return webView.url?.path
    }
    
    var isLoading: Bool {
        return webView.isLoading
    }
    
    weak var navigationDelegate: WKNavigationDelegate? {
        didSet {
            webView.navigationDelegate = navigationDelegate
        }
    }
    
    weak var uiDelegate: WKUIDelegate? {
        didSet {
            webView.uiDelegate = uiDelegate
        }
    }
    
    weak var scrollViewDelegate: UIScrollViewDelegate? {
        didSet {
            webView.scrollView.delegate = scrollViewDelegate
        }
    }
    
    var allowsBackForwardNavigationGestures: Bool = false {
        didSet {
            webView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        }
    }
    
    weak var webView: WKWebView!
    private weak var progressView: UIProgressView?
    private var progressObserver: NSKeyValueObservation?
    private var javaScriptController: TSJavaScriptController?
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        print("\(String(describing: type(of: self))) - \(#function)")
        removeObserver()
    }
    
    private func initialize() {
        createWebView()
        createProgress()
        observeProgress()
    }
    
    private func observeProgress() {
        progressObserver = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard
                let self = self,
                let newValue = change.newValue
            else { return }
            let progress = Int(newValue * 100)
            self.progressView?.progress = Float(newValue)
            self.progressView?.isHidden = (progress >= 100)
        }
    }
    
    // MARK: - Progress
    func createProgress() {
        if progressView != nil { return }
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = UIColor(red: 245.0 / 255.0, green: 239.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        progressView.progressTintColor = UIColor(red: 138.0 / 255.0, green: 111.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
        progressView.isHidden = true
        webView.addSubview(progressView)
        if let superview = progressView.superview {
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
            progressView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
            progressView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
            progressView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        }
        self.progressView = progressView
    }
    
    // MARK: - WebView
    func createWebView() {
        let webView = TSCookieManager.shared.createWKWebView(CGRect.zero)
        webView.scrollView.bounces = false
//        webView.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        insertSubview(webView, at: 0)
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

// MARK: - Private
private extension TSWebView {
}

public extension TSWebView {
    func reCreateWebView() {
        removeObserver()
        webView.removeFromSuperview()
        webView = nil
        createWebView()
    }
    
    func removeObserver() {
        progressObserver?.invalidate()
        progressObserver = nil
    }
    
    func getWebView() -> WKWebView {
        return webView
    }
    
    func javaScriptEnable(name: String, target: AnyObject, protocol bridgeProtocol: Protocol) {
//        let javaScriptController = WKJavaScriptController(name: name, target: target, bridgeProtocol: bridgeProtocol)
//        webView.javaScriptController = javaScriptController
//        webView.prepareForJavaScriptController()
        let javaScriptController = TSJavaScriptController(name: name, target: target, bridgeProtocol: bridgeProtocol)
        webView.setJavaScriptController(javaScriptController)
        self.javaScriptController = javaScriptController
    }
    
    func addScriptMessageHandler(target: WKScriptMessageHandler, messages: [[String: Any]]?) {
        guard let messages = messages else { return }
        let target = LeakAvoiderScriptMessageHandler(delegate: target)
        messages.forEach { dic in
            if let name = dic["name"] as? String {
                webView.configuration.userContentController.add(target, name: name)
            }
        }
    }
    
    func removeScriptMessageHandler(messages: [[String: Any]]?) {
        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.removeAllScriptMessageHandlers()
            return
        }
        guard let messages = messages else { return }
        messages.forEach { dic in
            if let name = dic["name"] as? String {
                webView.configuration.userContentController.removeScriptMessageHandler(forName: name)
            }
        }
    }
    
    func load(URLString: String?) {
        guard let URLString = URLString else { return }
        if let URL = URL(string: URLString) {
            load(URL: URL)
        }
    }
    
    func load(URL: URL?) {
        guard let URL = URL else { return }
        let request = URLRequest(url: URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 35.0)
        load(request: request)
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func canGoBack() -> Bool {
        return webView.canGoBack
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func canGoForward() -> Bool {
        return webView.canGoForward
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func reload() {
        webView.reload()
    }
    
    func stopLoading() {
        webView.stopLoading()
    }
    
    func contentInset(_ contentInset: UIEdgeInsets) {
        webView.scrollView.contentInset = contentInset
    }
    
    func scrollIndicatorInsets(_ scrollIndicatorInsets: UIEdgeInsets) {
        webView.scrollView.scrollIndicatorInsets = scrollIndicatorInsets
    }
    
    func scrollToTop() {
        webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @objc func evaluateJavaScript(_ script: String?, completion: ((Any?, Error?) -> Void)? = nil) {
        guard let script = script, !script.isEmpty else { return }
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(script) { (response, error) in
                if let error = error {
                    print("evaluateJavaScript error = \(error)")
                }
                if let response = response {
                    print("evaluateJavaScript response = \(response)")
                }
                
                completion?(response, error)
            }
        }
    }
    
    func loadFileURL(_ URL: URL, allowingReadAccessTo: URL) {
        webView.loadFileURL(URL, allowingReadAccessTo: allowingReadAccessTo)
    }
}
