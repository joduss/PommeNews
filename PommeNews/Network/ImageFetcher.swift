//
//  ImageFetcher.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.06.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import UIKit

protocol ImageFetcher {
    func fetchImage(at url: URL, completion: @escaping (UIImage?) -> ())
    
    //Return size in bytes
    func cacheSize(completion: @escaping (UInt) -> ())
    func emptyCache()
}


