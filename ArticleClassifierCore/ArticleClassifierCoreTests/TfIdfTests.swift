//
//  TfIdfTests.swift
//  ArticleClassifierCoreTests-macOS
//
//  Created by Jonathan Duss on 03.03.19.
//

import XCTest
@testable import ArticleClassifierCore

class TfIdfTests: XCTestCase {
    
    private let text = "This is a test method for a test!"
    private let text2 = "I am another test!"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicTextProcessors() {

        self.measure {
            let tfIdf = TfIdf(texts: [text, text2])
            
            let textVector = tfIdf.tokenize(text)
            let expectedTextVector = ["this", "is", "a", "test", "method", "for", "a", "test"]
            
            XCTAssertEqual(expectedTextVector, textVector)
            
            let textTerms = tfIdf.termsIn(text: text)
            let expectedTextTerms = Set(["a", "for", "is", "method", "test", "this"])
            XCTAssertEqual(expectedTextTerms, textTerms)
            
            let textTermsVector = tfIdf.termVector(from: text)
            let expectedtextTermsVector = ["a", "for", "is", "method", "test", "this"]
            XCTAssertEqual(expectedtextTermsVector, textTermsVector)
            
            let tfIdfAllTermsVector = tfIdf.allTermsVector
            let tfIdfExpectedAllTermsVector = ["a", "am", "another","for", "i", "is", "method", "test", "this"]
            XCTAssertEqual(tfIdfExpectedAllTermsVector, tfIdfAllTermsVector)
            
            let tfIdfAllTerms = tfIdf.allTerms
            let tfIdfAllTermsExpected = Set(["a", "am", "another","for", "i", "is", "method", "test", "this"])
            XCTAssertEqual(tfIdfAllTermsExpected, tfIdfAllTerms)
        }
    }
    
    func testFrequency() {
        let tfIdf = TfIdf(texts: [text, text2])

        let termDocumentFrequency = tfIdf.termsDocumentFrequency
        let termDocumentFrequencyExpected = ["a": 1, "am" : 1, "another" : 1,
                                             "for" : 1, "i" : 1, "is" : 1,
                                             "method" : 1, "test" : 2, "this" : 1]
        XCTAssertEqual(termDocumentFrequencyExpected, termDocumentFrequency)
        
        let termFrequencyVector = tfIdf.termFrequencyVector(text: text)
        let termFrequencyVectorExpected = [
            1, // a
            0, // am
            0, // another
            1, // for
            0, // i
            1, // is
            1, // method
            1, // test
            1  // this
        ]
        XCTAssertEqual(termFrequencyVectorExpected, termFrequencyVector)
        
        let idfTermsToNumTextContainingTerm = tfIdf.invertedDocumentFrequencyVector()
        let idfTermsToNumTextContainingTermExpected: [Double]  = [
            log(2/1), // a
            log(2/1), // am
            log(2/1), // another
            log(2/1), // for
            log(2/1), // i
            log(2/1), // is
            log(2/1), // method
            log(2/2), // test
            log(2/1)  // this
        ]
        XCTAssertEqual(idfTermsToNumTextContainingTermExpected, idfTermsToNumTextContainingTerm)
    }



}
