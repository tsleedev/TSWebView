//
//  TSWebViewController.swift
//  TSFramework
//
//  Created by TAE SU LEE on 7/30/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

open class TSWebViewController: UIViewController {
    public let webView: TSWebView
    public lazy var retryView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        
        let label = UILabel()
        label.text = "Failed to load the page. Please try again."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.addTarget(self, action: #selector(retryLoading), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
        
        return view
    }()
    
    // MARK: - Initialize with WebView
    public init(webView: TSWebView) {
        self.webView = webView
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureUI()
    }
    
    open func createWebViewController(webView: TSWebView) -> TSWebViewController {
        return TSWebViewController(webView: webView)
    }
}

// MARK: - Public
public extension TSWebViewController {
    func showRetryView() {
        retryView.isHidden = false
    }
}

// MARK: - Setup
private extension TSWebViewController {
    /// Initialize and add subviews
    func setupViews() {
        view.addSubview(webView)
        view.addSubview(retryView)
        webView.uiDelegate = self
        webView.navigationDelegate = self
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
        
        retryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            retryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            retryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            retryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            retryView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// Initialize UI elements and localization
    func configureUI() {
        view.backgroundColor = .systemBackground
    }
}

// MARK: - Action
private extension TSWebViewController {
    @objc func retryLoading() {
        retryView.isHidden = true
        if let currentURL = webView.backForwardList.currentItem?.url {
            let request = URLRequest(url: currentURL)
            webView.load(request)
        }
    }
}
