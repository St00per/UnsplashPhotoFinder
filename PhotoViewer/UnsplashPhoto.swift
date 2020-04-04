//
//  UnsplashPhoto.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 02.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import Foundation

struct UnsplashPhoto: Decodable {
    let id: String
    let width: Int
    let height: Int
    let color: String
    let urls: URLs 
}
struct URLs: Decodable {
   let raw: String
   let full: String
   let regular: String
   let small: String
   let thumb: String
}

struct SearchRequestResult: Decodable {
    let total: Int
    let total_pages: Int
    let results: [UnsplashPhoto]
}
