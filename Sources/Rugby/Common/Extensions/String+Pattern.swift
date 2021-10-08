//
//  File.swift
//  
//
//  Created by ykkd on 2021/10/09.
//

import Foundation

extension String {
    var withoutExtension: Self {
        return (self as NSString).deletingPathExtension
    }
    func getIsWildCard(pattern: String) -> Bool {
        let pred = NSPredicate(format: "self LIKE %@", pattern)
        return !NSArray(object: self).filtered(using: pred).isEmpty
    }
}
