//
//  PrivacyPolicyVC.swift
//  PommeNews
//
//  Created by Jonathan Duss on 02.03.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var policyFileUrl = Bundle.main.url(forResource: "Privacy Policy", withExtension: "html")!
        
        self.webview.loadFileURL(policyFileUrl, allowingReadAccessTo: policyFileUrl)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
