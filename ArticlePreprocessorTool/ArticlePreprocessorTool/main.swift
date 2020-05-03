//
//  main.swift
//  ArticlePreprocessorTool
//
//  Created by Jonathan Duss on 02.05.20.
//  Copyright © 2020 ZaJo. All rights reserved.
//

import Foundation
import ZaJoLibrary
import ArticleClassifierCore


var arguments = CommandLine.arguments

guard arguments.count == 3 else {
    fputs("usage: ArticlePreprocessorTool", stderr)
    exit(1)
}

let parameterInputFile = arguments[1]
let parameterOutputFile = arguments[2]

let articlesToProcess = try ArticlesJsonFileIO().loadVerifiedArticlesFrom(fileLocation: parameterInputFile)
let firstArticle = articlesToProcess.first!
let processor = ACTextPreprocessor(representativeText: firstArticle.title + firstArticle.summary)

var processedArticle = [TCVerifiedArticle](articlesToProcess)


// Concurrency management
let group = DispatchGroup()
let semaphore = DispatchSemaphore(value: 1)
let queue = OperationQueue()
queue.maxConcurrentOperationCount = 16



func processArticle(_ article: TCVerifiedArticle) -> TCVerifiedArticle {
    let title = processor.process(text: article.title)
    let summary = processor.process(text: article.summary)
    return article.articleWithUpdated(title: title, summary: summary)
}


func getUpdateProgress(){
    semaphore.wait()
    queue.progress.completedUnitCount += 1
    semaphore.signal()
}

queue.progress.totalUnitCount = Int64(articlesToProcess.count)

for i in 0..<articlesToProcess.endIndex {
    group.enter()
    queue.addOperation {
        let article = articlesToProcess[i]
        processedArticle[i] = processArticle(article)
        if (queue.progress.completedUnitCount % 10 == 0) {
            print("Finished processing article \(queue.progress.completedUnitCount)/\(queue.progress.totalUnitCount) (\(queue.progress.fractionCompleted * 100))")
        }
        group.leave()
    }
}

print("Now just waiting that all are processed")
group.wait()


try ArticlesJsonFileIO().WriteToFile(articles: processedArticle, at: parameterOutputFile)

fputs(String(data: ArticleJsonConverter.convertToJson(articles: processedArticle), encoding: .utf8), stdout)
