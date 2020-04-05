//
//  String+Extension.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 05.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}
