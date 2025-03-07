//
//  main.swift
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

import Foundation

let apiKey = "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"

let directory = "/Users/mahdiabbasian/Documents/Android/Workspace/flutter_poolakey"
let gitUtility = GitDiffUtility(directoryPath: directory)

do {
    let stagedFiles = try gitUtility.getStagedFiles()
    print("Staged Files: \(stagedFiles)")
    
    if stagedFiles.isEmpty {
        print("No staged files found. Please stage your changes with 'git add' first.")
        exit(1)
    }
    
    let diff = try gitUtility.getDiff(files: stagedFiles)
    print("Diff:\n\(diff)")
    
    if diff.isEmpty {
        print("No changes detected in staged files.")
        exit(1)
    }
    
    let apiClient: APIClient = OpenAICommitClient(apiKey: apiKey)
    
    do {
        let commitMessages = try await apiClient.generateCommitMessage(previousMessages: [], newUserMessage: diff)
        
        print("\n--- Generated Commit Messages ---")
        for (index, message) in commitMessages.enumerated() {
            print("\nOption \(index + 1):")
            print(message)
        }
    } catch APIError.missingAPIKey {
        print("Error: Please provide your actual OpenAI API key in the code.")
        exit(1)
    } catch {
        print("Error generating commit message: \(error.localizedDescription)")
        exit(1)
    }
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}
