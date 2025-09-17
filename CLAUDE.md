# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TSWebView is an iOS/macOS WebView framework built on WKWebView with enhanced JavaScript bridge capabilities, cookie management, and UI enhancements. It provides seamless bidirectional communication between native and web contexts.

## Build & Development Commands

```bash
# Build the framework
swift build

# Run tests
swift test

# Open in Xcode
open Package.swift

# Work with the demo app
cd Example/TSWebViewDemo && open TSWebViewDemo.xcodeproj
```

## Core Architecture

### Key Components

1. **TSWebView** (`Sources/TSWebView/TSWebView.swift`): Main WebView class extending WKWebView
   - Progress indicator with customizable styling
   - Shared process pool via `WebProgressPoolManager` singleton
   - Async/await JavaScript evaluation

2. **TSWebViewController** (`Sources/TSWebView/TSWebViewController.swift`): WebView container
   - Auto-configured as WKNavigationDelegate/WKUIDelegate (see extension files)
   - Retry mechanism for failed loads
   - Modal/navigation dismissal handling

3. **TSJavaScriptController** (`Sources/TSWebView/Utils/TSJavaScriptController.swift`): Protocol-based JS bridge
   - Type-safe interface using `JavaScriptInterface` protocol
   - Automatic method discovery via Objective-C runtime
   - Memory leak prevention with `LeakAvoiderScriptMessageHandler`

4. **TSCookieManager** (`Sources/TSWebView/TSCookieManager.swift`): Cookie synchronization
   - Bridges WKHTTPCookieStore and HTTPCookieStorage
   - Async/await operations

### JavaScript Bridge Pattern

The framework uses a protocol-based approach for JavaScript communication:
1. Define an Objective-C protocol extending `JavaScriptInterface`
2. Implement the protocol in a handler class
3. Register with `TSJavaScriptController`
4. Methods are automatically exposed to JavaScript

Example:
```swift
@objc protocol MyJSInterface: JavaScriptInterface {
    func handleAction(_ params: [String: Any])
}
```

### Memory Management

- All JavaScript message handlers use weak references to prevent retain cycles
- Process pool is shared across WebView instances for memory efficiency
- Proper observer cleanup in deinit methods

## Testing

Tests are minimal - when adding features, consider expanding test coverage in `Tests/TSWebViewTests/`.

## Important Notes

- Minimum iOS 13.0, Swift 5.8+
- No external dependencies - pure Swift implementation
- Extensions organize delegate implementations separately
- Gemini AI code review configured (see `.gemini/styleguide.md`)