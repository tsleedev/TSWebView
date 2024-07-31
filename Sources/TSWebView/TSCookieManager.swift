//
//  TSCookieManager.swift
//  TSFramework
//
//  Created by TAE SU LEE on 2021/07/08.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import WebKit

@MainActor
public struct TSCookieManager {}

// MARK: - Private (Web)
private extension TSCookieManager {
    func _syncWebCookie(cookie: HTTPCookie) async {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        await cookieStore.setCookie(cookie)
    }
    
    func _deleteWebCookie(cookies: [HTTPCookie]) async {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        for cookie in cookies {
            await cookieStore.deleteCookie(cookie)
        }
    }
}

// MARK: - Public (Web)
extension TSCookieManager {
    func webCookie(name: String) async -> [HTTPCookie] {
        let cookies = await allWebCookies()
        return cookies.filter { $0.name == name }
    }
    
    func allWebCookies() async -> [HTTPCookie] {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        return await cookieStore.allCookies()
    }
    
    func syncWebCookie(_ cookie: HTTPCookie, onlyName: String? = nil) async {
        if let onlyName = onlyName, cookie.name != onlyName { return }
        await _syncWebCookie(cookie: cookie)
    }
    
    func syncWebCookies(_ cookies: [HTTPCookie], onlyName: String? = nil) async {
        for cookie in cookies {
            await syncWebCookie(cookie, onlyName: onlyName)
        }
    }
    
    func deleteWebCookie(name: String) async {
        let cookies = await webCookie(name: name)
        await _deleteWebCookie(cookies: cookies)
    }
    
    func deleteAllWebCookies(name: String) async {
        let cookies = await allWebCookies()
        await _deleteWebCookie(cookies: cookies)
    }
}

// MARK: - Public (API)
extension TSCookieManager {
    func apiCookie(name: String) -> [HTTPCookie] {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return [] }
        return cookies.filter { $0.name == name }
    }
    
    func apiCookie(domain: String) -> [HTTPCookie] {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return [] }
        return cookies.filter { $0.domain.contains(domain) }
    }
    
    func syncApiCookie(_ cookie: HTTPCookie, onlyName: String? = nil) {
        if let onlyName = onlyName, cookie.name != onlyName { return }
        deleteApiCookie(name: cookie.name)
        HTTPCookieStorage.shared.setCookie(cookie)
    }
    
    func syncApiCookies(_ cookies: [HTTPCookie], onlyName: String? = nil) {
        cookies.forEach { cookie in
            syncApiCookie(cookie, onlyName: onlyName)
        }
    }
    
    func deleteApiCookie(name: String) {
        let cookies = apiCookie(name: name)
        cookies.forEach { cookie in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
    
    func deleteApiCookie(domain: String) {
        let cookies = apiCookie(domain: domain)
        cookies.forEach { cookie in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
    
    func deleteAllApiCookies() {
        HTTPCookieStorage.shared.cookies?.forEach { cookie in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
}

// MARK: - Public (Common)
extension TSCookieManager {
    func syncCookie(_ cookie: HTTPCookie) async {
        syncApiCookie(cookie)
        await syncWebCookie(cookie)
    }
    
    func syncCookies(_ cookies: [HTTPCookie]) async {
        syncApiCookies(cookies)
        await syncWebCookies(cookies)
    }
    
    func deleteCookie(_ name: String) async {
        deleteApiCookie(name: name)
        await deleteWebCookie(name: name)
    }
}
