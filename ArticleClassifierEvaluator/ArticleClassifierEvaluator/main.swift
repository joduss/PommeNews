//
//  main.swift
//  ArticleClassifierEvaluator
//
//  Created by Jonathan Duss on 10.06.19.
//  Copyright © 2019 ZaJo. All rights reserved.
//

import Foundation
import ArticleClassifierCore

//==========================================
//Configuration of the classifier evaluator
//==========================================
let languageToTest = "fr"

//for all theme, use ArticleTheme.allThemes
//let themesToEvaluate : [ArticleTheme] = [ ArticleTheme.netflix ]
let themesToEvaluate: [ArticleTheme] =
    [
        ArticleTheme.mac,
        ArticleTheme.appleWatch,
        ArticleTheme.iPhone,
        ArticleTheme.iPad,
        ArticleTheme.ios,
        ArticleTheme.appleTV,
        ArticleTheme.music,
        ArticleTheme.apple,
        ArticleTheme.google,
        ArticleTheme.macos,
        ArticleTheme.samsung,
        ArticleTheme.smartphone,
        ArticleTheme.tablet,
        ArticleTheme.android,
        ArticleTheme.netflix,
        ArticleTheme.spotify,
        ArticleTheme.facebook,
        ArticleTheme.microsoft,
        ArticleTheme.video,
        ArticleTheme.computer,
        ArticleTheme.patent

    ]


//==========================================
// Don't touch
//==========================================

let filePath = Bundle.main.path(forResource: "articles-evaluation_" + languageToTest, ofType: "json", inDirectory: nil)!
let evaluator = Evaluator()


print("==============================")
print("Starting evaluation for language " + languageToTest)
print("==============================")

//evaluator.startEvaluation(articlesFile: filePath, themes: themesToEvaluate)


print("==============================")
print("Starting precision and recall for language " + languageToTest)
print("==============================")

evaluator.precisionAndRecall(articleLocation: filePath, themes: themesToEvaluate, verbose: false)





exit(0)
