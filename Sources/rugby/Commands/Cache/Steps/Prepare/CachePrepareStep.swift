//
//  CachePrepareStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import ShellOut
import XcodeProj

struct CachePrepareStep: Step {
    struct Output {
        let scheme: String?
        let remotePods: Set<String>
        let checksums: [String]
        let products: Set<String>
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Cache
    private let metrics: Metrics

    init(command: Cache, metrics: Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Prepare", logFile: logFile, verbose: verbose)
    }
}

extension CachePrepareStep {

    func run(_ buildTarget: String) throws -> Output {
        if try shellOut(to: "xcode-select -p") == .defaultXcodeCLTPath {
            throw CacheError.cantFineXcodeCommandLineTools
        }

        progress.print("Read project ⏱".yellow)
        metrics.projectSize.before = (try Folder.current.subfolder(at: .podsProject)).size()
        let project = try XcodeProj(pathString: .podsProject)
        metrics.compileFilesCount.before = project.pbxproj.buildFiles.count
        metrics.targetsCount.before = project.pbxproj.main.targets.count
        let factory = CacheSubstepFactory(progress: progress, command: command, metrics: metrics)
        let pods = try factory.findRemotePods(project)
        let (buildPods, remoteChecksums) = try factory.findBuildPods(pods)
        let (targets, buildTargets) = try factory.buildTargets((project: project, pods: pods, buildPods: buildPods))
        let targetsNames = Set(targets.map(\.name))
        if !buildTargets.isEmpty {
            let dependencies = buildTargets.union(targetsNames)
            try factory.addBuildTarget(.init(target: buildTarget, project: project, dependencies: dependencies))
        }
        let products = Set(targets.compactMap(\.product?.name))

        done()
        return Output(scheme: buildTargets.isEmpty ? nil : buildTarget,
                      remotePods: targetsNames.union(pods),
                      checksums: remoteChecksums,
                      products: products)
    }
}