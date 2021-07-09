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

        title = "Use Storyboard"
        
        webView.javaScriptEnable(target: self, protocol: JavaScriptInterface.self)
        webView.load(URLString: "https://tswebviewhosting.web.app")
    }
}

// MARK: -
extension StoryboardWebViewController: JavaScriptInterface {
    func openNewWebView(_ response: Any) {
        print("openNewWebView")
    }
    
    func closeWebView(_ response: Any) {
        print("closeWebView")
    }
    
    
}
