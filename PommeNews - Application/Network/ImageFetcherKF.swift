//
//  ImageFetcherKF.swift
//  PommeNews
//
//  Created by Jonathan Duss on 26.07.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

class ImageFetcherKF: ImageFetcher {
    
    private let manager: KingfisherManager
    
    init() {
        self.manager = KingfisherManager.shared
        manager.cache.maxDiskCacheSize = 100000000
    }
    
    func fetchImage(at url: URL, completion: @escaping (UIImage?) -> ()) {
        
        manager.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: {
            image, _, _, _ in completion(image)
        })
        
        cacheSize(completion: { size in print(size) })
    }
    
    func emptyCache() {
        manager.cache.clearDiskCache()
    }
    
    func cacheSize(completion: @escaping (UInt) -> ()) {
        manager.cache.calculateDiskCacheSize(completion: { size in
            completion(size)
        })
    }
    
}
