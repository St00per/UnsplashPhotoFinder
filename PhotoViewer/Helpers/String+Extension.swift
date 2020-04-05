//
//  String+Extension.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 05.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//
import Foundation

extension String {

    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }

    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9_]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }

}
