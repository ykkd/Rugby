//
//  DropRun.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

import Files

extension Drop: Command {
    mutating func run(logFile: File) throws -> Metrics {
        if testFlight { verbose = true }
        let metrics = DropMetrics(project: project.basename())
        let factory = DropStepFactory(command: self, metrics: metrics, logFile: logFile)
        let (targets, products) = try factory.prepare(none)
        try factory.remove(.init(targets: targets, products: products))
        return metrics
    }
}

/// Shortcut for Void()
let none: Void = ()