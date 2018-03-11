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
    
    private var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webview = WKWebView(frame: webviewContainer.frame, configuration: WKWebViewConfiguration())
        webviewContainer.addSubview(webview)
        let contraintsVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webview]|", options: .alignAllCenterY, metrics: nil, views: ["webview": webview])
        let contraintsHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: .alignAllCenterX, metrics: nil, views: ["webview": webview])

        self.webviewContainer.addConstraints(contraintsVertical)
        self.webviewContainer.addConstraints(contraintsHorizontal)
        self.webview.translatesAutoresizingMaskIntoConstraints = false

        let myURL = URL(string: "https://www.mac4ever.com/iphone/article?id=130490&page=1&app=true&base64=false&hd=false")
        let myRequest = URLRequest(url: myURL!)
        webview.load(myRequest)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
