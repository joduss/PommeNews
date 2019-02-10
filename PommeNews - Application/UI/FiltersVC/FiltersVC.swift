//
//  FiltersVC.swift
//  PommeNews
//
//  Created by Jonathan Duss on 20.09.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

class FiltersVC: UICollectionViewController {
    
    @IBOutlet weak var clearFiltersButton: UIBarButtonItem!
    
    private var supportedThemes: [Theme] = []
    private let colors = [#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1),#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1),#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1),#colorLiteral(red: 0.9199173373, green: 0.6700194326, blue: 1, alpha: 1),#colorLiteral(red: 0.3923459654, green: 0.9686274529, blue: 0.4062131187, alpha: 1),#colorLiteral(red: 0.5590454867, green: 0.9686274529, blue: 0.9379701674, alpha: 1),#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), #colorLiteral(red: 0.5218945424, green: 0.7424727168, blue: 0.8363196223, alpha: 1), #colorLiteral(red: 0.5234679263, green: 0.7023356541, blue: 0.5174741721, alpha: 1), #colorLiteral(red: 0.7023356541, green: 0.5134964426, blue: 0.6780128468, alpha: 1)]
    private let sideInset: CGFloat = 10
    
    private let themeFilters = ThemeFiltersPreferences()
    
    public var onSave: (([Theme]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        supportedThemes = themeFilters.allThemes
        
        clearFiltersButton.title = "filters.clear".localized
        collectionView?.allowsMultipleSelection = true
        
        let classname = String(describing: FilterVCCell.self)
        let nib = UINib(nibName: classname, bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: classname)
        
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView?.contentInset = UIEdgeInsets(top: sideInset, left: sideInset, bottom: sideInset, right: sideInset)
        
        let edgeLength = (self.collectionView!.frame.width - 3 * 10 - 2 * sideInset) / 4
        layout.itemSize = CGSize(width: edgeLength, height: edgeLength + 45)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return supportedThemes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = String(describing: FilterVCCell.self)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FilterVCCell
        cell.title = supportedThemes[indexPath.row].key.localized
        cell.image = UIImage(named: supportedThemes[indexPath.row].key)
        cell.layer.cornerRadius = 10
        cell.iconBackgroundColor = colors[indexPath.row % colors.count]
        
        let activeFiltersKeys = self.themeFilters.filteringThemes.map({$0.key})
        if activeFiltersKeys.contains(supportedThemes[indexPath.row].key) {
            self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            cell.isSelected = true
        }
        
        return cell
    }
    
    @IBAction func saveFilters(_ sender: Any) {
        let selectedIdx = self.collectionView?.indexPathsForSelectedItems ?? []
        let selectedThemes: [Theme] = selectedIdx.map({supportedThemes[$0.row]})
        
        themeFilters.filteringThemes = selectedThemes
        onSave?(selectedThemes)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearFilters(_ sender: Any) {
        for selectedIdx in self.collectionView?.indexPathsForSelectedItems ?? [] {
            self.collectionView?.deselectItem(at: selectedIdx, animated: true)
        }
    }
}
