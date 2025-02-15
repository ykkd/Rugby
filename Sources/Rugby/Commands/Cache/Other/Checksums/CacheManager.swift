//
//  CacheManager.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.03.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Yams

struct BuildCache: Codable {
    let sdk: SDK
    let arch: String?
    let config: String?
    let swift: String?
    let xcargs: [String]?
    let checksums: [String]?
}

private func cacheKey(sdk: SDK, config: String?) -> String {
    [config, sdk.xcodebuild]
        .compactMap { $0 }
        .joined(separator: "-")
}

typealias CacheFile = [String: BuildCache]

struct CacheManager {
    func load() -> CacheFile? {
        guard let cacheFileData = try? File(path: .cacheFile).read() else { return nil }
        let decoder = YAMLDecoder()
        // Format was changed, so parsing can fail
        let cacheFile = try? decoder.decode(CacheFile.self, from: cacheFileData)
        return cacheFile
    }

    func update(cache: BuildCache) throws {
        // Update only selected sdk cache
        var cacheFile = load() ?? [:]
        let key = cacheKey(sdk: cache.sdk, config: cache.config)
        cacheFile[key] = cache

        // Save
        let file = try Folder.current.createFileIfNeeded(at: .cacheFile)
        let encoder = YAMLEncoder()
        let cacheFileData = try encoder.encode(cacheFile)
        try file.write(cacheFileData)
    }
}

// MARK: - Load by key

extension CacheManager {
    func load(sdk: SDK, config: String?) -> BuildCache? {
        let key = cacheKey(sdk: sdk, config: config)
        return load()?[key]
    }
}

// MARK: - Checksums

extension CacheManager {
    func checksumsMap(sdk: SDK, config: String?) -> [String: Checksum] {
        load(sdk: sdk, config: config)?.checksumsMap() ?? [:]
    }
}

extension BuildCache {
    func checksumsMap() -> [String: Checksum] {
        (checksums ?? []).reduce(into: [:]) { checksums, element in
            guard let checksum = Checksum(string: element) else { return }
            checksums[checksum.name] = checksum
        }
    }
}
