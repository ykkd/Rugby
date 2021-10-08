//
//  File.swift
//  
//
//  Created by ykkd on 2021/10/09.
//

import Files
import Foundation

extension Folder {
    func findSubFolders(with pattern: String) -> [Folder] {
        return self.subfolders.filter { $0.name.getIsWildCard(pattern: pattern) }
    }
}
