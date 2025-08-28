# TSWebView

[![Version](https://img.shields.io/github/v/release/tsleedev/TSWebView?style=flat)](https://github.com/tsleedev/TSWebView/releases)
[![License](https://img.shields.io/cocoapods/l/TSWebView.svg?style=flat)](https://cocoapods.org/pods/TSWebView)
[![Platform](https://img.shields.io/cocoapods/p/TSWebView.svg?style=flat)](https://cocoapods.org/pods/TSWebView)
[![Swift Version](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)

A powerful and flexible WebView wrapper for iOS with enhanced JavaScript bridge capabilities.

## ✨ Features

- 🌐 **Enhanced WKWebView** - Built on top of WKWebView with additional features
- 🔗 **JavaScript Bridge** - Seamless communication between native and web
- 🛡️ **Error Handling** - Robust error handling and recovery mechanisms
- 🎯 **Type-Safe Interface** - Type-safe JavaScript interface for Swift
- 📱 **iOS Optimized** - Optimized for iOS performance and memory usage
- 🤖 **AI Code Review** - Automated code review with Gemini and Claude AI

## 📋 Requirements

- iOS 11.0+
- Swift 5.0+
- Xcode 12.0+

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

### CocoaPods

TSWebView is available through [CocoaPods](https://cocoapods.org). Add the following line to your Podfile:

```ruby
pod 'TSWebView', '~> 0.7.0'
```

Then run:
```bash
pod install
```

## 🚀 Usage

### Basic Setup

```swift
import TSWebView

// Create a TSWebView instance
let webView = TSWebView()

// Configure and load content
webView.load(URLRequest(url: URL(string: "https://example.com")!))

// Add to your view hierarchy
view.addSubview(webView)
```

### JavaScript Interface

```swift
// Set up JavaScript handler
let handler = JavaScriptHandler()
webView.configureJavaScriptInterface(handler: handler)

// Handle JavaScript messages
handler.onMessage = { message in
    print("Received from JS: \(message)")
}

// Send message to JavaScript
webView.evaluateJavaScript("handleNativeMessage('\(message)')")
```

### Advanced Configuration

```swift
// Custom WKWebView configuration
let config = WKWebViewConfiguration()
config.preferences.minimumFontSize = 10
config.allowsInlineMediaPlayback = true

let webView = TSWebView(configuration: config)
```

## 📱 Example Project

To run the example project:

1. Clone the repository
```bash
git clone https://github.com/tsleedev/TSWebView.git
```

2. Navigate to Example directory
```bash
cd TSWebView/Example
```

3. Install dependencies
```bash
pod install
```

4. Open and run
```bash
open TSWebViewDemo.xcworkspace
```

## 🛠️ Development

This project uses AI-powered code review:
- **Gemini Code Assist** - Automatic PR reviews in Korean
- **Claude AI** - Deep code analysis via GitHub Actions

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
- Added AI code review system
- Added Gemini Korean styleguide

### Version 0.6.0
- Initial public release
- Basic WebView functionality
- JavaScript bridge implementation

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