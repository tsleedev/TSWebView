//
//  LeakAvoiderScriptMessageHandler.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/08.
//

import WebKit

class LeakAvoiderScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
