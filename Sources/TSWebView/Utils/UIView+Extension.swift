//
//  UIView+Extension.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/10.
//

import UIKit

extension UIView {
    // 뷰컨트롤러 찾기
    var viewController: UIViewController? {
        if let vc = self.next as? UIViewController {
            return vc
        } else if let superView = self.superview {
            return superView.viewController
        } else {
            return nil
        }
    }
}
