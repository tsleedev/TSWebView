//
//  TSCookieType.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/08.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import Foundation

protocol TSCookieType {}

extension TSCookieType {
    func makeCookie(_ cookie: HTTPCookie) -> String {
        var cookieString = "document.cookie='\(cookie.name)=\(cookie.value);path=\(cookie.path);domain=\(cookie.domain);"
        if let expiresDate = cookie.expiresDate {
            if expiresDate < Date() {
                cookieString += "Max-Age=0;"
            } else {
                cookieString += "expires=\(expiresDate);"
            }
        }
        cookieString += "';"
        return cookieString
    }
    
    func makeCookie(domain: String, name: String, value: String, expiresDate: Date? = nil) -> HTTPCookie? {
        var properties: [HTTPCookiePropertyKey: Any] = [.domain: domain,
                                                        .name: name,
                                                        .path: "/",
                                                        .value: value]
        if let expiresDate = expiresDate {
            if expiresDate < Date() {
                properties[HTTPCookiePropertyKey.maximumAge] = 0
            } else {
                properties[HTTPCookiePropertyKey.expires] = expiresDate
            }
        }
        return HTTPCookie(properties: properties)
    }
    
    func makeCookies(from cookiesString: String?, domain: String) -> [HTTPCookie] {
        guard let cookiesString = cookiesString else { return [] }
        
        var cookies: [HTTPCookie] = []
        cookiesString
            .components(separatedBy: ";")
            .forEach { cookieString in
                if let startIndex = cookieString.range(of: "=")?.lowerBound,
                   let endIndex = cookieString.range(of: "=")?.upperBound {
                    let name = String(cookieString[..<startIndex]).trimmingCharacters(in: .whitespaces)
                    let value = String(cookieString[endIndex..<cookieString.endIndex]).trimmingCharacters(in: .whitespaces)
                    if let cookie = makeCookie(domain: domain, name: name, value: value) {
                        cookies.append(cookie)
                    }
                }
            }
        return cookies
    }
    
    func findCookie(name: String, cookies: [HTTPCookie]?) -> [HTTPCookie]? {
        guard let cookies = cookies else { return nil }
        let filteredCookies = cookies.filter { $0.name == name }
        if filteredCookies.count > 0 {
            return filteredCookies
        }
        return nil
    }
}
