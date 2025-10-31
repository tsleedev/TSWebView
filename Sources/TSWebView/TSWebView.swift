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

// MARK: - TSWebViewConfiguration
public struct TSWebViewConfiguration {
    public var showsProgress: Bool
    public var isInspectable: Bool
    public var progressTrackColor: UIColor
    public var progressTintColor: UIColor

    public init(
        showsProgress: Bool = false,
        isInspectable: Bool = false,
        progressTrackColor: UIColor = UIColor(
            red: 245.0 / 255.0, green: 239.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        progressTintColor: UIColor = UIColor(
            red: 138.0 / 255.0, green: 111.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    ) {
        self.showsProgress = showsProgress
        self.isInspectable = isInspectable
        self.progressTrackColor = progressTrackColor
        self.progressTintColor = progressTintColor
    }
}

// MARK: - TSWebView
open class TSWebView: WKWebView, Identifiable {
    public let id: String = UUID().uuidString

    public static var applictionNameForUserAgent: String = "TSWebView/1.0"

    private weak var progressView: UIProgressView?
    private var progressObserver: NSKeyValueObservation?
    private var javaScriptController: TSJavaScriptController?
    private let tsConfiguration: TSWebViewConfiguration

    public convenience init(configuration: TSWebViewConfiguration = .init()) {
        let wkConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        wkConfiguration.applicationNameForUserAgent = Self.applictionNameForUserAgent
        wkConfiguration.userContentController = userContentController
        wkConfiguration.allowsInlineMediaPlayback = true
        wkConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes(
            rawValue: 0)
        wkConfiguration.processPool = WebProgressPoolManager.shared.progressPoll

        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        wkConfiguration.preferences = wkPreferences
        self.init(frame: .zero, configuration: wkConfiguration, tsConfiguration: configuration)
    }

    public init(
        frame: CGRect,
        configuration: WKWebViewConfiguration,
        tsConfiguration: TSWebViewConfiguration = .init()
    ) {
        self.tsConfiguration = tsConfiguration
        super.init(frame: frame, configuration: configuration)
        applyConfiguration()
    }

    required public init?(coder: NSCoder) {
        self.tsConfiguration = .init()
        super.init(coder: coder)
        applyConfiguration()
    }

    deinit {
        print("deinit \(self)")
        removeObserver()
    }

    private func applyConfiguration() {
        if tsConfiguration.isInspectable {
            enableWebInspector()
        }
        if tsConfiguration.showsProgress {
            enableProgressIndicator()
        }
    }

    // MARK: - Configuration Methods
    public func enableProgressIndicator() {
        guard progressView == nil else { return }
        createProgress(
            trackColor: tsConfiguration.progressTrackColor,
            tintColor: tsConfiguration.progressTintColor
        )
        observeProgress()
    }

    public func disableProgressIndicator() {
        progressView?.removeFromSuperview()
        progressView = nil
        removeObserver()
    }

    public func enableWebInspector() {
        if #available(iOS 16.4, *) {
            self.isInspectable = true
        }
    }

    public func disableWebInspector() {
        if #available(iOS 16.4, *) {
            self.isInspectable = false
        }
    }

    private func observeProgress() {
        guard progressObserver == nil else { return }
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
    private func createProgress(trackColor: UIColor, tintColor: UIColor) {
        if progressView != nil { return }
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = trackColor
        progressView.progressTintColor = tintColor
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
