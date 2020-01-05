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

class ViewController: NSViewController {

    @IBOutlet weak var buttonsView: NSView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var gridview: NSGridView!
    @IBOutlet weak var dropdown: NSPopUpButton!
    @IBOutlet weak var statsLabel: NSTextField!
    @IBOutlet weak var goToTF: NSTextField!
    
    private let rowCount = 16.0
    
    private var articleFilePath: String? = nil
    private var articles: [TCArticle] = []
    private let themes = ArticleTheme.allThemes
    
    private let jsonArticlesIO = ArticlesJsonFileIO()
    private let converter = ArticleJsonConverter()
    
    private var countArticleWithoutThemes = 0
    
    private let DropDownOptionInOrder = "In Order"
    private let DropDownOptionRandom = "Random"
    private let DropDownOptionRandomNoTheme = "Random no theme"

    private var currentArticle: TCArticle? {
        didSet {
            var summaryCleaned = currentArticle?.summary ?? ""
            summaryCleaned = summaryCleaned.replacingOccurrences(of: "\n", with: "\\n")
            summaryCleaned = summaryCleaned.replacingOccurrences(of: "\t", with: "")

            textView.string = """
            \(currentArticle!.title)
            
            \(summaryCleaned)
            """
            goToTF.stringValue = "\(articles.firstIndex(of: currentArticle!)!)"
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

        for theme in themes {
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
        
        guard let character = event.characters?.first, let article = currentArticle else {
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
        
        var themes = article.themes

        if let themeIdx = themes.firstIndex(of: theme.key) {
            themes.remove(at: themeIdx)
        }
        else {
            themes.append(theme.key)
        }
        
        let mutatedArticle = TCArticle(title: article.title,
                                       summary: article.summary,
                                       themes: themes)
        
        articles[articles.firstIndex(of: article)!] = mutatedArticle
        currentArticle = mutatedArticle
        
        updateCheckboxes()
    }
    
    @IBAction func load(_ sender: Any) {
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
                    self.articles = try jsonArticlesIO.loadArticlesFrom(fileLocation: path)
                    self.articleFilePath = path
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
            try jsonArticlesIO.WriteToFile(articles: articles, at: path)
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
                let currentIdx = articles.firstIndex(of: currentArticle)!
                self.currentArticle = articles[currentIdx + 1]
            }
            else {
                currentArticle = articles.first
            }
        case .Random:
            self.currentArticle = articles[Int.random(in:0..<articles.count)]
        case .RandomNoTheme:
            let articlesWithoutTheme = articles.filter({$0.themes.isEmpty})
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
        
        currentArticle = articles[idx]
    }
    
    @objc
    private func themeSelected(sender: NSButton) {
        guard let article = currentArticle else {
            return
        }
        
        var themes = article.themes
        let clickedTheme = ArticleTheme.init(key: sender.title)
        
        if sender.state == .on {
            themes.append(clickedTheme.key)
        }
        else {
            themes.remove(at: themes.firstIndex(of: clickedTheme.key)!)
        }
        
        let mutatedArticle = TCArticle(title: article.title,
                                       summary: article.summary,
                                       themes: themes)
        articles[articles.firstIndex(of: article)!] = mutatedArticle
        currentArticle = mutatedArticle
    }
    
    /// Updates stats
    private func updateStats() {
        
        if articles.isEmpty {
            statsLabel.stringValue = "there are no articles"
        }
        
        countArticleWithoutThemes = 0
        for article in articles {
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

