//
//  api.swift
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

import Foundation

public struct ChatMessage: Identifiable, Hashable {
    public var id = UUID()
    public var text: String
    public var isUser: Bool
    
    public init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
    }
}
    
public protocol APIClient {
    func generateCommitMessage(previousMessages: [ChatMessage], newUserMessage: String) async throws -> [CommitMessage]
}

public class OpenAICommitClient: APIClient {
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private var apiKey: String = "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"
    private let model: String
    
    public init(apiKey: String, model: String = "gpt-3.5-turbo") {
        self.apiKey = apiKey
        self.model = model
    }
    
    private func createRequest(messages: [[String: Any]]) throws -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        return request
    }
    
    public func generateCommitMessage(previousMessages: [ChatMessage], newUserMessage: String) async throws -> [CommitMessage] {
        let systemMessage: [String: Any] = [
            "role": "system",
            "content": "Create git commit messages following the conventional commit convention, ensuring they are clear and concise. For each change, provide an explanation. Based on the output from 'git diff --staged', craft a commit message and description. Use present tense, keep lines under 74 characters, and respond in English",
        ]
        
        let trainingMessage: [String: Any] = [
            "role": "user",
            "content": """
           diff --git a/src/server.ts b/src/server.ts
           index ad4db42..f3b18a9 100644
           --- a/src/server.ts
           +++ b/src/server.ts
           @@ 10,7 +10,7 @@
           import {
               initWinstonLogger();
                       
               const app = express();
               -const port = 7799;
               +const PORT = 7799;
                       
               app.use(express.json());
                       
           @@ -34,6 +34,6 @@
           app.use((_, res, next) => {
               // ROUTES
               app.use(PROTECTED_ROUTER_URL, protected Router);
                       
               -app.listen(port, () => {
               -   console.log('Server listening on port ${port}');
               +app.listen(process.env.PORT || PORT, () => {
               +   console.log("Server listening on port ${PORT}');
               });
           """,
        ]
        
        let assistantMessage: [String: Any] = [
            "role": "assistant",
            "content": """
                 [
                 {
                     "message": "Change port variable case from lowercase port to uppercase PORT",
                     "description": "The port variable is now named PORT, which improves consistency with the 
                                     naming conventions as PORT is a constant. Support for an environment variable allows
                                     the application to be more flexible as it can now run on any available port specified
                                     via the process.env.PORT environment variable."
                 },
                 {
                     "message": "Add support for process.env. PORT environment variable",
                     "description": "The port variable is now named PORT, which improves consistency with the
                                     naming conventions as PORT is a constant. Support for an environment variable allows
                                     the application to be more flexible as it can now run on any available port specified
                                     via the process.env. PORT environment variable."
                     }
                 ]
                 """,
        ]
        
        let userMessages = previousMessages.map { message -> [String: Any] in
            [
                "role": message.isUser ? "user": "assistant",
                "content": message.text,
            ]
        }
        
        let newUserMessageObject: [String: Any] = [
            "role": "user",
            "content": newUserMessage,
        ]
        
        let messages = [systemMessage, trainingMessage, assistantMessage] + userMessages + [newUserMessageObject]
        
        let request = try createRequest(messages: messages)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let response = try decoder.decode(OpenAIResponse.self, from: data)
            
            guard let responseText = response.choices.first?.message.content else {
                throw APIError.invalidResponse
            }
            return [
                CommitMessage(
                    message: responseText.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: "Automatically generated commit message"
                )
            ]
            
            guard let jsonData = responseText.data(using: .utf8) else {
                throw APIError.decodingError(NSError(domain: "Encoding", code: 0))
            }
            return try decoder.decode([CommitMessage].self, from: jsonData)
            
        } catch {
            throw error
        }
        
    }
}
    

            
struct OpenAIResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let usage: OpenAIUsage
    let choices: [OpenAIChoice]
}
                         
struct OpenAIChoice: Decodable {
    let message: OpenAIMessage
    let finish_reason: String
    let index: Int
    var text: String {
        return message.content
    }
}
                         
struct OpenAIMessage: Decodable {
    let role: String
    let content: String
}

struct OpenAIUsage: Decodable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}
