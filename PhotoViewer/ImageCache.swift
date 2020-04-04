//
//  ImageCache.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 04.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

class ImageCache {

    static let cache = URLCache(
        memoryCapacity: memoryCapacity,
        diskCapacity: diskCapacity,
        diskPath: "unsplash"
    )
    static let memoryCapacity: Int = 50.megabytes
    static let diskCapacity: Int = 100.megabytes

}

private extension Int {
    var megabytes: Int { return self * 1024 * 1024 }
}
