//
//  PommeNewsConfig.swift
//  PommeNews
//
//  Created by Jonathan Duss on 27.12.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

class PommeNewsConfig {
    public static let GoogleAppId = "ca-app-pub-4180653915602895~3091606580"
    public static var AdUnitBanner: String { get
    {
        #if DEBUG
        return "ca-app-pub-4180653915602895/9111710711"
        #else
        return "ca-app-pub-3940256099942544/2934735716"
        #endif
        }
    }
}
