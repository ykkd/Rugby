//
//  CacheRun.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

import Files

extension Cache: Command {
    func run(logFile: File) throws -> Metrics {
        let metrics = CacheMetrics(project: String.podsProject.basename())
        let factory = CacheStepsFactory(command: self, metrics: metrics, logFile: logFile)
        let info = try factory.prepare(.buildTarget)
        try factory.build(.init(scheme: info.scheme, checksums: info.checksums))
        try factory.integrate(info.remotePods)
        try factory.cleanup(.init(scheme: info.scheme, pods: info.remotePods, products: info.products))
        return metrics
    }
}