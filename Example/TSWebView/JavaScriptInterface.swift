//
//  JavaScriptInterface.swift
//  TSWebView
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit

// Create protocol.
// '@objc' keyword is required. because method call is based on ObjC.
@objc protocol JavaScriptInterface {
    func openNewWebView(_ response: [String: Any])
    func closeWebView(_ response: [String: Any])
}
