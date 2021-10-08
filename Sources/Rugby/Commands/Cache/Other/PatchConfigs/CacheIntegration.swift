//
//  CacheIntegration.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct CacheIntegration {
    let cacheFolder: String
    let buildedTargets: Set<String>

    func replacePathsToCache() throws {
        let supportFilesFolder = try Folder.current.subfolder(at: .podsTargetSupportFiles)
        let originalDirs = ["PODS_CONFIGURATION_BUILD_DIR", "BUILT_PRODUCTS_DIR"].joined(separator: "|")
        let suffixPods = buildedTargets.map { $0.escapeForRegex() }.joined(separator: "|")
        let fileRegex = [#".*-resources\.sh"#, #".*\.xcconfig"#, #".*-frameworks\.sh"#].joined(separator: "|")
        try FilePatcher().replace(#"\$\{(\#(originalDirs))\}(?=\/(\#(suffixPods))("|\s|\/))"#,
                                  with: cacheFolder,
                                  inFilesByRegEx: "(\(fileRegex))",
                                  folder: supportFilesFolder)
    }

    func fixSubFoldersPath() throws {
        let cacheFolder = try Folder.current.subfolder(at: cacheFolder)
        let foldersNeedsMoved = cacheFolder.findSubFolders(with: "*.framework")
        try foldersNeedsMoved.forEach { folder in
            let parent = try cacheFolder.createSubfolder(named: folder.name.withoutExtension)
            try folder.move(to: parent)
        }
    }
}
