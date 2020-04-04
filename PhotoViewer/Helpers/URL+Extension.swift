//
//  URL+Extension.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 02.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import Foundation

extension URL {
    private static var baseUrl: String {
        return "https://api.unsplash.com/"
    }
    
    static func with(string: String) -> URL? {
        return URL(string: "\(baseUrl)\(string)")
    }
}
