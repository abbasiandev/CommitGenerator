//
//  git.swift
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

import Foundation

public class GitDiffUtility {
    private let executor: ShellCommandExecutor
    private let directoryPath: String
    
    public init(directoryPath: String, executor: ShellCommandExecutor = SystemShellExecutor()) {
        self.directoryPath = directoryPath
        self.executor = executor
    }
    
    public func getStagedFiles() throws -> [String] {
        let isGitDirCommand = "cd '\(directoryPath)' && git rev-parse --is-inside-work-tree"
        
        do {
            let _ = try executor.execute(isGitDirCommand)
            
            let stagedFilesCommand = "cd '\(directoryPath)' && git diff --cached --name-only"
            let stagedFilesOutput = try executor.execute(stagedFilesCommand)
            
            return stagedFilesOutput.isEmpty ? [] : stagedFilesOutput.split(separator: "\n").map { String($0) }
        } catch {
            print("Git repository error: \(error.localizedDescription)")
            return []
        }
    }
    
    public func getDiff(files: [String]) throws -> String {
        let filesString = files.joined(separator: " ")
        return try executor.execute("cd '\(directoryPath)' && git diff --staged -- \(filesString)")
    }
}
