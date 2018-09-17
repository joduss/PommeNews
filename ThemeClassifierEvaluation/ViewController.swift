//
//  ViewController.swift
//  ThemeClassifierEvaluation2
//
//  Created by Jonathan Duss on 04.09.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        NSLog("Starting")
        
        let themesToEvaluate: [ArticleTheme] = [ArticleTheme.mac]
        
        Evaluator().startEvaluation(articleLocation: Bundle.main.path(forResource: "articles", ofType: "json")!, themes: themesToEvaluate)
    }


}

