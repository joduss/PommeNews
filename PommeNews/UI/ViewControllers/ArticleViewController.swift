//
//  ArticleViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController {

    @IBOutlet weak var webviewContainer: UIView!
    private let webview: WKWebView
    
    required init?(coder aDecoder: NSCoder) {
        self.webview = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.translatesAutoresizingMaskIntoConstraints = false
        
        webviewContainer.addSubview(webview)
        let contraintsVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webview]|", options: .alignAllCenterY, metrics: nil, views: ["webview": webview])
        let contraintsHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: .alignAllCenterX, metrics: nil, views: ["webview": webview])
        
        self.webviewContainer.addConstraints(contraintsVertical)
        self.webviewContainer.addConstraints(contraintsHorizontal)
        self.webview.navigationDelegate = self

    }

    func load(url: URL, title: String) {
        webview.stopLoading()
        let myRequest = URLRequest(url: url)
        webview.load(myRequest)
        self.title = title
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webview.stopLoading()
        webview.load(URLRequest(url: URL(string:"about:blank")!))
        super.viewDidDisappear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ArticleViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        self.title = "didCommit"
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.title = "didFinish"
    }
    
}
