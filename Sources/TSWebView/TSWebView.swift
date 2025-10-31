//
//  TSWebView.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/08.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import WebKit

class WebProgressPoolManager {
    static let shared = WebProgressPoolManager()
    var progressPoll = WKProcessPool()
    private init() {}
}

open class TSWebView: WKWebView, Identifiable {
    public let id: String = UUID().uuidString

    public static var applictionNameForUserAgent: String = "TSWebView/1.0"

    private weak var progressView: UIProgressView?
    private var progressObserver: NSKeyValueObservation?
    private var javaScriptController: TSJavaScriptController?

    public convenience init(showsProgress: Bool = true, isInspectable: Bool = false) {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        configuration.applicationNameForUserAgent = Self.applictionNameForUserAgent
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes(
            rawValue: 0)
        configuration.processPool = WebProgressPoolManager.shared.progressPoll

        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = wkPreferences
        self.init(frame: .zero, configuration: configuration)
        initialize(showsProgress: showsProgress, isInspectable: isInspectable)
    }

    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        initialize(showsProgress: true, isInspectable: false)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize(showsProgress: true, isInspectable: false)
    }

    deinit {
        print("deinit \(self)")
        removeObserver()
    }

    private func initialize(showsProgress: Bool, isInspectable: Bool) {
        if #available(iOS 16.4, *) {
            self.isInspectable = isInspectable
        }
        if showsProgress {
            createProgress()
            observeProgress()
        }
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
        progressView.trackTintColor = UIColor(
            red: 245.0 / 255.0, green: 239.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        progressView.progressTintColor = UIColor(
            red: 138.0 / 255.0, green: 111.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
        progressView.isHidden = true
        addSubview(progressView)
        if let superview = progressView.superview {
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive =
                true
            progressView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0)
                .isActive = true
            progressView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0)
                .isActive = true
            progressView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        }
        self.progressView = progressView
    }
}

extension TSWebView {
    public func removeObserver() {
        progressObserver?.invalidate()
        progressObserver = nil
    }

    public func javaScriptEnable(target: AnyObject, protocol bridgeProtocol: Protocol) {
        let javaScriptController = TSJavaScriptController(
            target: target, bridgeProtocol: bridgeProtocol)
        setJavaScriptController(javaScriptController)
        self.javaScriptController = javaScriptController
    }

    @available(iOS 14.0, *)
    public func removeAllScriptMessageHandlers() {
        configuration.userContentController.removeAllScriptMessageHandlers()
    }

    public func removeScriptMessageHandler(messages: [[String: Any]]?) {
        guard let messages = messages else { return }
        messages.forEach { dic in
            if let name = dic["name"] as? String {
                configuration.userContentController.removeScriptMessageHandler(forName: name)
            }
        }
    }

    public func load(urlString: String?) {
        guard let urlString = urlString else { return }
        if let url = URL(string: urlString) {
            load(url: url)
        }
    }

    public func load(url: URL?) {
        guard let url = url else { return }
        let request = URLRequest(
            url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 35.0)
        load(request)
    }

    public func evaluateJavaScript(_ script: String?, completion: ((Any?, Error?) -> Void)? = nil) {
        guard let script = script, !script.isEmpty else { return }
        DispatchQueue.main.async {
            super.evaluateJavaScript(script) { (response, error) in
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

    @MainActor
    public override func evaluateJavaScript(_ script: String?) async throws -> Any? {
        guard let script = script, !script.isEmpty else { return nil }

        do {
            let response = try await super.evaluateJavaScript(script)
            if let response = response {
                print("TSWebView evaluateJavaScript response = \(response)")
            }
            return response
        } catch {
            print("TSWebView evaluateJavaScript error = \(error)")
            throw error
        }
    }
}
