//
//  TfIdfTests.swift
//  ArticleClassifierCoreTests-macOS
//
//  Created by Jonathan Duss on 03.03.19.
//

import XCTest
@testable import ArticleClassifierCore

class TfIdfTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTextProcessors() {
        let text = "This is a test method for a test!"
        let text2 = "I am another test!"

        let tfIdf = TfIdf(texts: [text, text2])
        
        let textVector = tfIdf.tokenize(text)
        let expectedTextVector = ["this", "is", "a", "test", "method", "for", "a", "test"]

        XCTAssertEqual(expectedTextVector, textVector)
        
        let textTerms = tfIdf.termsIn(text: text)
        let expectedTextTerms = Set(["a", "for", "is", "method", "test", "this"])
        XCTAssertEqual(expectedTextTerms, textTerms)
        
        let textTermsVector = tfIdf.termsVector(from: text)
        let expectedtextTermsVector = ["a", "for", "is", "method", "test", "this"]
        XCTAssertEqual(expectedtextTermsVector, textTermsVector)
        
        let tfIdfAllTermsVector = tfIdf.allTermsVector
        let tfIdfExpectedAllTermsVector = ["a", "am", "another","for", "i", "is", "method", "test", "this"]
        XCTAssertEqual(tfIdfExpectedAllTermsVector, tfIdfAllTermsVector)
        
        let tfIdfAllTerms = tfIdf.allTerms
        let tfIdfAllTermsExpected = Set(["a", "am", "another","for", "i", "is", "method", "test", "this"])
        XCTAssertEqual(tfIdfAllTermsExpected, tfIdfAllTerms)

        let tfIdfTermsToNumTextContainingTerm = tfIdf.termsTextContainingTerm
        let tfIdfTermsToNumTextContainingTermExpected = ["a": 1, "am" : 1, "another" : 1,
                                                         "for" : 1, "i" : 1, "is" : 1,
                                                         "method" : 1, "test" : 2, "this" : 1]
        XCTAssertEqual(tfIdfTermsToNumTextContainingTermExpected, tfIdfTermsToNumTextContainingTerm)

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
