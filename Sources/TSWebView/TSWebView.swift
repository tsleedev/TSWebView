//
//  TSWebView.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/08.
//

import WebKit

open class TSWebView: WKWebView {
    private weak var progressView: UIProgressView?
    private var progressObserver: NSKeyValueObservation?
    private var javaScriptController: TSJavaScriptController?
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    deinit {
        print("deinit \(self)")
        removeObserver()
    }
    
    private func initialize() {
        if #available(iOS 16.4, *) {
            isInspectable = true
        }
        createProgress()
        observeProgress()
    }
    
    private func observeProgress() {
        progressObserver = observe(\.estimatedProgress, options: .new) { [weak self] _, change in
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
        addSubview(progressView)
        if let superview = progressView.superview {
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
            progressView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
            progressView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
            progressView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        }
        self.progressView = progressView
    }
}

public extension TSWebView {
    func removeObserver() {
        progressObserver?.invalidate()
        progressObserver = nil
    }
    
    func javaScriptEnable(target: AnyObject, protocol bridgeProtocol: Protocol) {
        let javaScriptController = TSJavaScriptController(target: target, bridgeProtocol: bridgeProtocol)
        setJavaScriptController(javaScriptController)
        self.javaScriptController = javaScriptController
    }
    
    func addScriptMessageHandler(target: WKScriptMessageHandler, messages: [[String: Any]]?) {
        guard let messages = messages else { return }
        let target = LeakAvoiderScriptMessageHandler(delegate: target)
        messages.forEach { dic in
            if let name = dic["name"] as? String {
                configuration.userContentController.add(target, name: name)
            }
        }
    }
    
    func removeScriptMessageHandler(messages: [[String: Any]]?) {
        if #available(iOS 14.0, *) {
            configuration.userContentController.removeAllScriptMessageHandlers()
            return
        }
        guard let messages = messages else { return }
        messages.forEach { dic in
            if let name = dic["name"] as? String {
                configuration.userContentController.removeScriptMessageHandler(forName: name)
            }
        }
    }
    
    func load(urlString: String?) {
        guard let urlString = urlString else { return }
        if let url = URL(string: urlString) {
            load(url: url)
        }
    }
    
    func load(url: URL?) {
        guard let url = url else { return }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 35.0)
        load(request)
    }
    
    @objc func evaluateJavaScript(_ script: String?, completion: ((Any?, Error?) -> Void)? = nil) {
        guard let script = script, !script.isEmpty else { return }
        DispatchQueue.main.async {
            self.evaluateJavaScript(script) { (response, error) in
                if let error = error {
                    print("TSWebView evaluateJavaScript error = \(error)")
                }
                if let response = response {
                    print("TSWebView evaluateJavaScript response = \(response)")
                }
                
                completion?(response, error)
            }
        }
    }
}
