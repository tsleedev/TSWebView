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
    func openNewWebView(_ response: Any)
    func closeWebView(_ response: Any)
    func goBack(_ response: Any)
    func openExternalWebView(_ response: Any)
    func outlink(_ response: Any)
}
