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
        
//        let themesToEvaluate: [ArticleTheme] = [ArticleTheme.mac,
//                                                ArticleTheme.appleWatch,
//                                                ArticleTheme.iPhone,
//                                                ArticleTheme.iPad,
//                                                ArticleTheme.ios,
//                                                ArticleTheme.appleTV,
//                                                ArticleTheme.music,
//                                                ArticleTheme.apple,
//                                                ArticleTheme.google,
//                                                ArticleTheme.macos,
//                                                ArticleTheme.samsung,
//                                                ArticleTheme.smartphone,
//                                                ArticleTheme.tablet,
//                                                ArticleTheme.android
//        ]
        
        let themesToEvaluate = ArticleTheme.allThemes
        
//        Evaluator().startEvaluation(articleLocation: Bundle.main.path(forResource: "articles", ofType: "json")!, themes: themesToEvaluate)
        
        let articlesDataLocation = Bundle.main.path(forResource: "articles-evaluation", ofType: "json")!
        
        Evaluator().precisionAndRecall(articleLocation: articlesDataLocation, themes: themesToEvaluate, verbose: true)
        
        
        exit(0)
    }


}

