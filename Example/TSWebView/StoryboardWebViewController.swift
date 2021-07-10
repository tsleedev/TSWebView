//
//  StoryboardWebViewController.swift
//  TSWebView
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit
import TSWebView

class StoryboardWebViewController: UIViewController {
    @IBOutlet private weak var webView: TSWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storyboard"
        
        webView.javaScriptEnable(target: self, protocol: JavaScriptInterface.self)
        webView.load(URLString: "https://tswebviewhosting.web.app")
    }
}

// MARK: - JavaScriptInterface
extension StoryboardWebViewController: JavaScriptInterface {
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
