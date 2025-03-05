//
//  main.swift
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

import Foundation

let directory = "/Users/mahdiabbasian/Documents/Android/Workspace/bisthoosh"
let gitUtility = GitDiffUtility(directoryPath: directory)

let stagedFiles = try gitUtility.getStagedFiles()
print("Staged Files: \(stagedFiles)")


let diff = try gitUtility.getDiff(files: stagedFiles)
print("Diff:\n\(diff)")

let apiClient: APIClient = OpenAICommitClient(apiKey: "your_api_key")

let commitMessage = try await apiClient.generateCommitMessage(previousMessages: [], newUserMessage: diff)
print(commitMessage)

//if let jsonData = commitMessage.data(using: .utf8) {
//    let decoder = JSONDecoder()
//    do {
//        let items = try decoder.decode([CommitMessage].self, from: jsonData)
//        print(items)
//    } catch {
//        print(error)
//    }
//}
