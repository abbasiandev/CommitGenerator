//
//  Untitled.swift
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

import Foundation

public protocol ShellCommandExecutor {
    func execute(_ command: String) throws -> String
}

public class SystemShellExecutor: ShellCommandExecutor {
    public init() {}
    
    public func execute(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "CommandError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to read command output"])
            }
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw NSError(domain: "CommandError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Command execution failed: \(error.localizedDescription)"])
        }
    }
}
