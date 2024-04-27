//
//  MainViewController.swift
//  TSWebView
//
//  Created by TAE SU LEE on 2021/07/08.
//

import UIKit

enum WebViewType {
    case storyboard
    case codeBase
    case opensource
}

extension WebViewType {
    var title: String {
        switch self {
        case .storyboard:
            return "Make by Storyboard"
        case .codeBase:
            return "Make by CodeBase"
        case .opensource:
            return "Make by Opensource"
        }
    }
}

class MainViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let types: [WebViewType] = [.storyboard, .codeBase, .opensource]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TSWebView"
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = types[indexPath.row].title
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = types[indexPath.row]
        switch type {
        case .storyboard:
            performSegue(withIdentifier: "storyboard", sender: nil)
        case .codeBase:
            let destination = CodeBaseWebViewController()
            navigationController?.pushViewController(destination, animated: true)
        case .opensource:
            break
        }
    }
}
