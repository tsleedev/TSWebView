//
//  CodeBaseWebViewController.swift
//  TSWebView_Example
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit
import TSWebView

class CodeBaseWebViewController: UIViewController {
    private weak var webView: TSWebView!
    
    var url: String?
    var path: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CodeBase"
        
        setUI()
        webView?.javaScriptEnable(target: self, protocol: JavaScriptInterface.self)
        if let url = url {
            webView.load(URLString: url)
        } else if let path = path {
            webView.load(URLString: "https://tswebviewhosting.web.app\(path)")
        } else {
            webView.load(URLString: "https://tswebviewhosting.web.app")
        }
    }
}

// MARK: - Setup
private extension CodeBaseWebViewController {
    func setUI() {
        let webView = TSWebView()
        view.addSubview(webView)
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

// MARK: - JavaScriptInterface
extension CodeBaseWebViewController: JavaScriptInterface {
    func openNewWebView(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let path = dictionary["path"] as? String
        else { return }
        let destination = CodeBaseWebViewController()
        destination.path = path
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func closeWebView(_ response: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func goBack(_ response: Any) {
        if webView.canGoBack() {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
