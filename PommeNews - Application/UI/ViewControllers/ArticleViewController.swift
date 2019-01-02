//
//  ArticleViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds

class ArticleViewController: ViewControllerAdmob {
    
    @IBOutlet var progressView: UIProgressView!
    
    @IBOutlet weak var webviewContainer: UIView!
    fileprivate let webview: WKWebView
    
    private var url: URL!
    
    //MARK: - Life cycle
    //=======================================================
    
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
        
        self.progressView?.progress = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.presentedViewController == nil  {
            webview.stopLoading()
            webview.load(URLRequest(url: URL(string:"about:blank")!))
            webview.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        }
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if webview.estimatedProgress == 1 {
            self.progressView.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //if (Reachability)
        //TODO: reachability test
    }
    
    //MARK: - Setup - Loading page
    //=======================================================
    
    func load(url: URL, title: String) {
        self.url = url
        webview.stopLoading()
        let myRequest = URLRequest(url: url)
        
        self.progressView?.progress = 0
        self.progressView?.alpha = 1
        webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        webview.load(myRequest)
        self.title = title
    }
    
    //MARK: - Actions
    //=======================================================
    
    @IBAction func shareClicked(_ sender: Any) {
        
        let safariActivity = SafariActivity()
        
        let activityController = UIActivityViewController(activityItems: [self.url], applicationActivities: [safariActivity])
        present(activityController, animated: true, completion: nil)
    }
}


//MARK: - Progress
//=======================================================

extension ArticleViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard object is WKWebView, keyPath == #keyPath(WKWebView.estimatedProgress) else { return }
        
        
        progressView?.setProgress(Float(webview.estimatedProgress),
                                  animated: true)
        
        if progressView?.progress == 1 {
            UIView.animate(withDuration: 0.2, animations: { self.progressView.alpha = 0 })
        }
    }
}
