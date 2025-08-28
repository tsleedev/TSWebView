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
    private var animatingToVisible: Bool? = nil  // 현재 애니메이션 방향 추적
    private var originalTabBarY: CGFloat?
    
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
    
    func setTabBarVisible(_ response: Any) {
        guard let dictionary = response as? [String: Any],
              let visible = dictionary["visible"] as? Bool
        else { return }
        
        // 애니메이션 중이고 같은 방향이면 무시
        if isAnimatingTabBar, let currentDirection = animatingToVisible, currentDirection == visible {
            return
        }
        
        guard let tabBar = viewController?.tabBarController?.tabBar else { return }
        
        // 원래 위치 저장 (첫 호출 시에만)
        if originalTabBarY == nil {
            originalTabBarY = tabBar.frame.origin.y
        }
        
        guard let originalY = originalTabBarY else { return }
        
        // 현재 presentation layer의 위치 가져오기 (애니메이션 중인 실제 위치)
        let currentY = tabBar.layer.presentation()?.frame.origin.y ?? tabBar.frame.origin.y
        
        // 애니메이션 중이면 현재 위치에서 시작하도록 설정
        if isAnimatingTabBar {
            tabBar.layer.removeAllAnimations()
            tabBar.frame.origin.y = currentY
        }
        
        isAnimatingTabBar = true
        animatingToVisible = visible  // 현재 애니메이션 방향 저장
        
        if visible {
            tabBar.isHidden = false
        }
        
        // 남은 거리에 따라 애니메이션 시간 조정
        let targetY = visible ? originalY : originalY + tabBar.frame.height
        let totalDistance = tabBar.frame.height
        let remainingDistance = abs(targetY - currentY)
        let duration = totalDistance > 0 ? 0.3 * (remainingDistance / totalDistance) : 0
        
        UIView.animate(withDuration: duration) {
            if visible {
                // 원래 위치로 복원
                tabBar.frame.origin.y = originalY
            } else {
                // 아래로 이동 (탭바 높이만큼)
                tabBar.frame.origin.y = originalY + tabBar.frame.height
            }
        } completion: { [weak self] finished in
            guard let self else { return }
            
            // 애니메이션 완료 처리
            self.isAnimatingTabBar = false
            self.animatingToVisible = nil
            
            if finished && !visible {
                tabBar.isHidden = true
            }
            
            if finished {
                guard let callback = dictionary["callbackId"] as? String else { return }
                let script = "\(callback)();"
                webView.evaluateJavaScript(script, completion: nil)
            }
        }
    }
    
    func setSwipeGestureEnabled(_ response: Any) {
        guard let dictionary = response as? [String: Any],
              let enabled = dictionary["enabled"] as? Bool
        else { return }
        webView.allowsBackForwardNavigationGestures = enabled
        guard let callback = dictionary["callbackId"] as? String else { return }
        let script = "\(callback)();"
        webView.evaluateJavaScript(script, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        guard let viewController = viewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default)
        alert.addAction(confirmAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
