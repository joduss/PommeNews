//
//  ViewController.swift
//  ArticleThemeTruthMaker
//
//  Created by Jonathan Duss on 22.06.19.
//  Copyright © 2019 ZaJo. All rights reserved.
//

import Cocoa
import ArticleClassifierCore

fileprivate enum NavigationMode {
    case InOrder
    case Random
    case RandomNoTheme
}

class ManualTaggingVC: NSViewController {

    @IBOutlet weak var buttonsView: NSView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var gridview: NSGridView!
    @IBOutlet weak var dropdown: NSPopUpButton!
    @IBOutlet weak var statsLabel: NSTextField!
    @IBOutlet weak var goToTF: NSTextField!
    
    private let DropDownOptionInOrder = "In Order"
    private let DropDownOptionRandom = "Random"
    private let DropDownOptionRandomNoTheme = "Random no theme"
    
    private let rowCount = 16.0
    
    private let allThemes = ArticleTheme.allThemes

    private let jsonArticlesIO = ArticlesJsonFileIO()
    private var articleFilePath: String? = nil

    private var articles: [Int : TCVerifiedArticle] = [:]
    private var articlesHashArray: [Int] = []
    private var countArticleWithoutThemes = 0
    

    private var currentArticle: TCVerifiedArticle? {
        willSet {
            guard  let currentArticle = self.currentArticle else { return }
            articles[currentArticle.hashValue] = currentArticle
        }
        didSet {
            var summaryCleaned = currentArticle?.summary ?? ""
            summaryCleaned = summaryCleaned.replacingOccurrences(of: "\n", with: "\\n")
            summaryCleaned = summaryCleaned.replacingOccurrences(of: "\t", with: "")

            textView.string = """
            \(currentArticle!.title)
            
            \(summaryCleaned)
            """
            goToTF.stringValue = "\(articlesHashArray.firstIndex(of: currentArticle!.hashValue)!)"
            updateCheckboxes()
            
            updateStats()
        }
    }
    
    private var navigationMode: NavigationMode {
        switch dropdown.titleOfSelectedItem {
        case DropDownOptionInOrder:
            return .InOrder
        case DropDownOptionRandom:
            return .Random
        case DropDownOptionRandomNoTheme:
            return .RandomNoTheme
        default:
            return .InOrder
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        
        dropdown.removeAllItems()
        dropdown.addItem(withTitle: DropDownOptionInOrder)
        dropdown.addItem(withTitle: DropDownOptionRandom)
        dropdown.addItem(withTitle: DropDownOptionRandomNoTheme)
        dropdown.selectItem(withTag: 0)
        
        updateCheckboxes()
        updateStats()
    }
    
    private func updateCheckboxes() {
        var currentPosition = 0.0

        for theme in allThemes {
            var row = 0.0
            var col = 0.0
            
            if currentPosition != 0 {
                col = floor(currentPosition / rowCount)
                row = currentPosition - col * rowCount
            }
            
            let view = gridview.cell(atColumnIndex: Int(col), rowIndex: Int(row))
            
            var button: NSButton! = view.contentView as? NSButton
            
            if button == nil {
                button = NSButton(checkboxWithTitle: theme.key, target: self, action: #selector(themeSelected))
                view.contentView = button
                button.translatesAutoresizingMaskIntoConstraints = false
                button.widthAnchor.constraint(equalToConstant: 150).isActive = true
            }
            
            
            if let article = currentArticle, article.themes.contains(theme.key) {
                button.state = .on
            }
            else {
                button.state = .off
            }
            
            currentPosition += 1
        }
    }

    override func keyUp(with event: NSEvent) {
        print(event.keyCode)
    
        if let specialKey = event.specialKey {
            if specialKey == NSEvent.SpecialKey.leftArrow {
                previous()
            }
            else if specialKey == NSEvent.SpecialKey.rightArrow {
                next(self)
            }
            
            return
        }
        
        guard let character = event.characters?.first else {
            return
        }
        
        var themeFromKey: ArticleTheme?
        
        switch event.characters {
        case "a":
            themeFromKey = ArticleTheme.apple
        case "t":
            themeFromKey = ArticleTheme.tablet
        case "f":
            themeFromKey = ArticleTheme.facebook
        case "m":
            themeFromKey = ArticleTheme.mac
        case "g":
            themeFromKey = ArticleTheme.google
        case "i":
            themeFromKey = ArticleTheme.iPhone
        case "r":
            themeFromKey = ArticleTheme.rumor
        case "k":
            themeFromKey = ArticleTheme.keynote
        case "p":
            themeFromKey = ArticleTheme.iPad
        case "e":
            themeFromKey = ArticleTheme.economyPolitic
        case "c":
            themeFromKey = ArticleTheme.computer
        case "w":
            themeFromKey = ArticleTheme.watch
        case "n":
            themeFromKey = ArticleTheme.netflix
        case "b":
            themeFromKey = ArticleTheme.beta
        case "d":
            themeFromKey = ArticleTheme.disneyPlus
        case "z":
            themeFromKey = ArticleTheme.ios
        case "u":
            themeFromKey = ArticleTheme.macos
        case "s":
            themeFromKey = ArticleTheme.smartphone
        case "h":
            themeFromKey = ArticleTheme.health
        case "l":
            themeFromKey = ArticleTheme.lawsuitLegal
        case "z":
            themeFromKey = ArticleTheme.amazon
        default:
            break
        }
        
        guard let theme = themeFromKey else {
            return
        }
        
        if let themeIdx = allThemes.firstIndex(of: theme) {
            currentArticle?.themes.remove(at: themeIdx)
        }
        else {
            currentArticle?.themes.append(theme.key)
        }
        
        currentArticle?.verifiedThemes = ArticleTheme.allThemes.map({$0.key})
        
        updateCheckboxes()
    }
    
    
    /// Load all the articles
    @IBAction func load(_ sender: Any) {
        
        // Cleanup
        
        articles = [:]
        articlesHashArray = []
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .json file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["json"];
        
        do {
            if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                let result = dialog.url // Pathname of the file
                
                if (result != nil) {
                    let path = result!.path
                    self.articleFilePath = path

                    let loadedArticles = try jsonArticlesIO.loadVerifiedArticlesFrom(fileLocation: path)
                    
                    for loadedArticle in loadedArticles {
                        let articleHash = loadedArticle.hashValue
                        articlesHashArray.append(articleHash)
                        articles[articleHash] = loadedArticle
                    }
                    
                    currentArticle = articles[articlesHashArray.first!]
                    
                }
            }
        }
        catch {
            self.showError(error)
        }
        
        self.updateStats()
    }
    
    @IBAction func save(_ sender: Any) {
        guard let path = self.articleFilePath else {
            return
        }
        do {
            // We want to keep the same order in the json.
            var orderedArticles = Array<TCVerifiedArticle>()
            orderedArticles.reserveCapacity(articles.count)
            for hash in articlesHashArray {
                orderedArticles.append(articles[hash]!)
            }
            try jsonArticlesIO.WriteToFile(articles: orderedArticles, at: path)
        }
        catch {
            statsLabel.stringValue = "Saving failed. \(error.localizedDescription)"
        }
    }
    
    @IBAction func next(_ sender: Any) {
        guard articles.isEmpty == false else {
            textView.string = "no articles. Please load something first!"
            return
        }
        
        switch navigationMode {
        case .InOrder:
            if let currentArticle = self.currentArticle {
                let currentIdx = articlesHashArray.firstIndex(of: currentArticle.hashValue)!
                
                if (currentIdx+1 == articles.count) { return }
                
                self.currentArticle = articles[articlesHashArray[currentIdx + 1]]
            }
            else {
                currentArticle = articles[articlesHashArray.first!]
            }
        case .Random:
            self.currentArticle = articles[Int.random(in:0..<articles.count)]
        case .RandomNoTheme:
            let articlesWithoutTheme = articles.filter({$0.value.themes.isEmpty})
            self.currentArticle = articlesWithoutTheme[Int.random(in:0..<articlesWithoutTheme.count)]
        }
        
        updateCheckboxes()
    }
    
    private func previous() {
        var idx = Int(goToTF.stringValue) ?? 0
        idx -= 1
        guard idx < articles.count else {
            textView.string = "Index out of bound!"
            return
        }
        
        currentArticle = articles[idx]
    }

    @IBAction func GoTo(_ sender: Any) {
        let idx = Int(goToTF.stringValue) ?? 0
        guard idx < articles.count else {
            textView.string = "Index out of bound!"
            return
        }
        
        currentArticle = articles[articlesHashArray[idx]]
    }
    
    @objc
    private func themeSelected(sender: NSButton) {
        guard let article = currentArticle else {
            return
        }
        
        var themes = article.themes
        let clickedTheme = ArticleTheme.init(key: sender.title)
        
        if sender.state == .on {
            currentArticle?.themes.append(clickedTheme.key)
        }
        else {
            currentArticle?.themes.remove(at: themes.firstIndex(of: clickedTheme.key)!)
        }
        
        currentArticle?.verifiedThemes = ArticleTheme.allThemes.map({$0.key})
    }
    
    /// Updates stats
    private func updateStats() {
        
        if articles.isEmpty {
            statsLabel.stringValue = "there are no articles"
        }
        
        countArticleWithoutThemes = 0
        for article in articles.values {
            if article.themes.isEmpty {
                countArticleWithoutThemes += 1
            }
        }
        
        statsLabel.stringValue = "Without theme: \(countArticleWithoutThemes) / \(articles.count)"
    }
    
    //MARK: - Helpers
    //===================================================================
    
    private func showError(_ error: Error) {
        if let error = error as? NAError {
            switch error {
            case .error(let message):
                textView.string = message
            }
        }
        else {
            textView.string = error.localizedDescription
        }
    }

}

