//
//  ImageFetcher.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.06.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import UIKit

class ImageFetcher {
    
    private let imageUrl: URL
    
    init(imageUrl: URL) {
        self.imageUrl = imageUrl
    }
    
    func fetch(completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: self.imageUrl)
                if let image = UIImage(data: data) {
                    completion(image)
                }
                else {
                    completion(nil)
                }
            }
            catch {
                print(error)
                completion(nil)
            }
        }
    }
    
}
