//
//  JavaScriptHandler.swift
//  TSWebViewDemo
//
//  Created by TAE SU LEE on 8/1/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import TSWebView
import UIKit

// MARK: - JavaScriptHandler
class JavaScriptHandler: NSObject, JavaScriptInterface {
    private weak var viewController: UIViewController?
    private let webView: TSWebView
    
    private var isAnimatingTabBar = false
    
    init(viewController: UIViewController, webView: TSWebView) {
        self.viewController = viewController
        self.webView = webView
    }
    
    func screenEvent(_ response: Any) {
        guard let dictionary = response as? [String: Any],
              let name = dictionary["name"] as? String
        else { return }
        let parameters = dictionary["parameters"] as? [String: Any]
        
        var message = "name = \(name)"
        if let parameters = parameters {
            message += ", parameters = \(parameters)"
        }
        
        showAlert(title: "screenEvent", message: message)
//        Analytics.screenEvent(name, parameters: parameters)
    }
    
    func logEvent(_ response: Any) {
        guard let dictionary = response as? [String: Any],
              let name = dictionary["name"] as? String
        else { return }
        let parameters = dictionary["parameters"] as? [String: Any]
        
        var message = "name = \(name)"
        if let parameters = parameters {
            message += ", parameters = \(parameters)"
        }
        
        showAlert(title: "logEvent", message: message)
//        Analytics.logEvent(name, parameters: parameters)
    }
    
    func setUserProperty(_ response: Any) {
        guard
            let dictionary = response as? [String: Any],
            let name = dictionary["name"] as? String,
            let value = dictionary["value"] as? String
        else { return }
        let message = "name = \(name), value = \(value)"
        showAlert(title: "setUserProperty", message: message)
//        Analytics.setUserProperty(value, forName: name)
    }
    
    func openPhoneSettings(_ response: Any) {
        guard let dictionary = response as? [String: Any] else { return }
        guard let setting = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(setting)
                
        guard let callback = dictionary["callbackId"] as? String else { return }
        let script = "\(callback)();"
        webView.evaluateJavaScript(script, completion: nil)
    }
    
    func showTabBar(_ response: Any) {
        guard let dictionary = response as? [String: Any], !isAnimatingTabBar else { return }
        guard let tabBar = viewController?.tabBarController?.tabBar, tabBar.isHidden else { return }
        
        isAnimatingTabBar = true
        tabBar.isHidden = false
        UIView.animate(withDuration: 0.3) {
            tabBar.frame.origin.y -= tabBar.frame.height
        } completion: { [weak self] _ in
            guard let self = self else { return }
            isAnimatingTabBar = false
            guard let callback = dictionary["callbackId"] as? String else { return }
            let script = "\(callback)();"
            webView.evaluateJavaScript(script, completion: nil)
        }
    }
    
    func hideTabBar(_ response: Any) {
        guard let dictionary = response as? [String: Any], !isAnimatingTabBar else { return }
        guard let tabBar = viewController?.tabBarController?.tabBar, !tabBar.isHidden else { return }
        
        isAnimatingTabBar = true
        UIView.animate(withDuration: 0.3) {
            tabBar.frame.origin.y += tabBar.frame.height
        } completion: { [weak self] _ in
            guard let self = self else { return }
            isAnimatingTabBar = false
            tabBar.isHidden = true
            guard let callback = dictionary["callbackId"] as? String else { return }
            let script = "\(callback)();"
            webView.evaluateJavaScript(script, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default)
        alert.addAction(confirmAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
