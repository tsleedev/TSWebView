# TSWebView

[![Version](https://img.shields.io/github/v/release/tsleedev/TSWebView?style=flat)](https://github.com/tsleedev/TSWebView/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![Swift Version](https://img.shields.io/badge/Swift-5.8+-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)

A powerful and flexible WebView wrapper for iOS with enhanced JavaScript bridge capabilities.

## ✨ Features

- 🌐 **Enhanced WKWebView** - Built on top of WKWebView with additional features
- 🔗 **JavaScript Bridge** - Seamless bidirectional communication between native and web
- 📊 **Progress Indicator** - Built-in progress bar for loading states
- 🍪 **Cookie Management** - Comprehensive cookie handling with `TSCookieManager`
- 🔄 **Retry Mechanism** - Built-in retry view for failed page loads
- 📱 **iOS Optimized** - Memory management and process pool optimization
- 🎯 **Type-Safe** - Protocol-based JavaScript interface
- 🤖 **AI Code Review** - Automated code review with Gemini and Claude AI

## 📋 Requirements

- iOS 13.0+
- Swift 5.8+
- Xcode 14.0+

## 📦 Installation

### Swift Package Manager

Add TSWebView to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/tsleedev/TSWebView.git", from: "0.7.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/tsleedev/TSWebView.git`
3. Select version: `Up to Next Major 0.7.0`

## 🚀 Usage

### Basic WebView Setup

```swift
import TSWebView

// Create a TSWebView instance
let webView = TSWebView()

// Load a URL
webView.load(url: URL(string: "https://example.com"))

// Or load with string
webView.load(urlString: "https://example.com")

// Add to your view hierarchy
view.addSubview(webView)
```

### Using TSWebViewController

```swift
import TSWebView

// Create WebViewController with a WebView
let webView = TSWebView()
let webViewController = TSWebViewController(webView: webView)

// Load content
webView.load(urlString: "https://example.com")

// Present or push the view controller
navigationController?.pushViewController(webViewController, animated: true)
```

### JavaScript Bridge Setup

```swift
// Define your JavaScript interface protocol
@objc protocol MyJavaScriptInterface {
    func handleMessage(_ message: String)
    func getData(_ callback: String)
}

// Implement the interface
class MyJavaScriptHandler: NSObject, MyJavaScriptInterface {
    func handleMessage(_ message: String) {
        print("Received from JS: \(message)")
    }
    
    func getData(_ callback: String) {
        // Send data back to JavaScript
        webView.evaluateJavaScript("\(callback)('Native data')")
    }
}

// Enable JavaScript bridge
let handler = MyJavaScriptHandler()
webView.javaScriptEnable(
    target: handler,
    protocol: MyJavaScriptInterface.self
)
```

### Cookie Management

```swift
let cookieManager = TSCookieManager()

// Get all cookies
let allCookies = await cookieManager.allWebCookies()

// Get specific cookie
let sessionCookies = await cookieManager.webCookie(name: "sessionId")

// Sync cookies
await cookieManager.syncWebCookie(cookie)

// Delete cookies
await cookieManager.deleteWebCookie(name: "sessionId")
```

### Advanced Configuration

```swift
// Custom WKWebView configuration
let webView = TSWebView()

// Set custom user agent
TSWebView.applictionNameForUserAgent = "MyApp/1.0"

// Handle navigation delegate
class MyViewController: TSWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom navigation handling is already set up
        // webView.navigationDelegate = self (automatic)
        // webView.uiDelegate = self (automatic)
    }
}

// Handle retry for failed loads
webViewController.showRetryView()
```

### Async/Await JavaScript Evaluation

```swift
// Using async/await
Task {
    do {
        let result = try await webView.evaluateJavaScript("document.title")
        print("Page title: \(result ?? "")")
    } catch {
        print("Error: \(error)")
    }
}

// Using completion handler
webView.evaluateJavaScript("document.title") { result, error in
    if let title = result as? String {
        print("Page title: \(title)")
    }
}
```

## 📱 Example Project

To run the example project:

1. Clone the repository
```bash
git clone https://github.com/tsleedev/TSWebView.git
```

2. Open the example project
```bash
cd TSWebView/Example/TSWebViewDemo
open TSWebViewDemo.xcodeproj
```

3. Run the project in Xcode

## 🛠️ Development

This project uses AI-powered code review:
- **Gemini Code Assist** - Automatic PR reviews in Korean
- **Claude AI** - Deep code analysis via GitHub Actions

### Project Structure

```
TSWebView/
├── Sources/TSWebView/
│   ├── TSWebView.swift                    # Main WebView class
│   ├── TSWebViewController.swift          # WebView controller
│   ├── TSCookieManager.swift              # Cookie management
│   └── Utils/
│       ├── TSJavaScriptController.swift   # JavaScript bridge
│       ├── TSCookieType.swift              # Cookie types
│       └── LeakAvoiderScriptMessageHandler.swift
└── Tests/
```

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

AI will automatically review your PR and provide feedback!

## 📝 Changelog

### Version 0.7.0 (Latest)
- Enhanced JavaScript interface and handler implementation
- Improved error handling and performance optimizations
- Added AI code review system with GitHub Actions
- Added Gemini Korean styleguide for automated reviews

### Version 0.6.0
- Initial public release
- Core WebView functionality
- JavaScript bridge implementation
- Cookie management system

## 👤 Author

**TaeSeong Lee**
- Email: tslee.dev@gmail.com
- GitHub: [@tsleedev](https://github.com/tsleedev)

## 📄 License

TSWebView is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## 🙏 Acknowledgments

- Thanks to all contributors
- Powered by AI code review from Gemini and Claude

---

**Made with ❤️ by tsleedev**