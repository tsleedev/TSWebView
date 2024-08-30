//
//  TSJavaScriptController.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/09.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import WebKit

extension WKWebView {
    func setJavaScriptController(_ controller: TSJavaScriptController) {
        controller.injectTo(configuration.userContentController)
    }
}

class TSJavaScriptController: NSObject {
    private weak var target: AnyObject?
    private let bridgeProtocol: Protocol
    
    private var bridgeList = [MethodBridge]()
    
    init(target: AnyObject, bridgeProtocol: Protocol) {
        self.target = target
        self.bridgeProtocol = bridgeProtocol
        super.init()
        parseBridgeProtocol()
    }
}

// MARK: - Class
private extension TSJavaScriptController {
    class MethodBridge {
        fileprivate var nativeSelector: Selector
        
        fileprivate var jsSelector: String {
            let selector = NSStringFromSelector(nativeSelector)
            let components = selector.components(separatedBy: ":")
            if components.isEmpty {
                return selector
            } else {
                return components.first!
            }
        }
        
        fileprivate init(nativeSelector selector: Selector) {
            nativeSelector = selector
        }
    }
}

// MARK: - Helper
private extension TSJavaScriptController {
    func parseBridgeProtocol() {
        guard let methodList = protocol_copyMethodDescriptionList(bridgeProtocol, true, true, nil) else { return }
        var list = Optional(methodList)
        while list?.pointee.name != nil {
            defer { list = list?.successor() }
            guard let selector = list?.pointee.name else { continue }
            let bridge = MethodBridge(nativeSelector: selector)
            bridgeList.append(bridge)
        }
        free(methodList)
    }
    
    func injectTo(_ userContentController: WKUserContentController) {
        userContentController.removeAllUserScripts()
        let target = LeakAvoiderScriptMessageHandler(delegate: self)
        for bridge in bridgeList {
            userContentController.removeScriptMessageHandler(forName: bridge.jsSelector)
            userContentController.add(target, name: bridge.jsSelector)
            print("inject \(bridge.jsSelector)")
        }
    }
}

private typealias CFunction = @convention(c) (AnyObject, Selector, Any) -> Void

extension TSJavaScriptController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let target = target,
            let bridge = bridgeList.first(where: { $0.jsSelector == message.name })
        else { return }
        
        guard let method = class_getInstanceMethod(target.classForCoder, bridge.nativeSelector) else {
            print("An unimplemented method has been called. (selector: \(bridge.nativeSelector))")
            return
        }
        
        let imp = method_getImplementation(method)
        unsafeBitCast(imp, to: CFunction.self)(target, bridge.nativeSelector, message.body)
    }
}
