//
//  TSNavigationController.swift
//  TSWebViewDemo
//
//  Created by TAE SU LEE on 7/30/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class TSNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 네비게이션 바가 숨겨져 있어도 스와이프 백 기능 활성화
        if navigationController.viewControllers.count > 1 {
            self.interactivePopGestureRecognizer?.isEnabled = true
            self.interactivePopGestureRecognizer?.delegate = nil
        } else {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
