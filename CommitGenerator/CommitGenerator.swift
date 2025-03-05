//
//  CommitGenerator.swift
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

import Foundation
import ArgumentParser

public struct CommitGenerator: AsyncParsableCommand {
    @Option(help: "The directory path for the git repository")
    public var directory: String = FileManager.default.currentDirectoryPath
    
    @Option(help: "OpenAI API Key")
    public var apiKey: String?
    
    public init() {}
    
    public mutating func run() async throws {
        guard let apiKey = apiKey ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw ValidationError("API Key is required. Use --api-key or set OPENAI_API_KEY environment variable.")
        }
        
        let gitUtility = GitDiffUtility(directoryPath: directory)
        let apiClient = OpenAICommitClient(apiKey: apiKey)
        
        do {
            let stagedFiles = try gitUtility.getStagedFiles()
            guard !stagedFiles.isEmpty else {
                print("No staged files found.")
                return
            }
            
            let diff = try gitUtility.getDiff(files: stagedFiles)
            let commitMessages = try await apiClient.generateCommitMessage(previousMessages: [], newUserMessage: diff)
            
            for message in commitMessages {
                print(message)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
