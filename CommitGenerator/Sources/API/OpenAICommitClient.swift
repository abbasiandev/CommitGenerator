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
    private var apiKey: String
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
            "model": model,
            "messages": messages,
            "response_format": ["type": "json_object"]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        return request
    }
    
    public func generateCommitMessage(previousMessages: [ChatMessage], newUserMessage: String) async throws -> [CommitMessage] {
        if apiKey.isEmpty || apiKey == "your_api_key" {
            throw APIError.missingAPIKey
        }
        
        let systemMessage: [String: Any] = [
            "role": "system",
            "content": "Create git commit messages following the conventional commit convention, ensuring they are clear and concise. For each change, provide an explanation. Based on the output from 'git diff --staged', craft a commit message and description. Use present tense, keep lines under 74 characters, and respond in JSON format like: [{\"message\": \"commit message\", \"details\": \"detailed explanation\"}]",
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
                 {
                   "commitMessages": [
                     {
                         "message": "refactor: change port variable case from lowercase to uppercase",
                         "details": "The port variable is now named PORT, which improves consistency with the naming conventions as PORT is a constant."
                     },
                     {
                         "message": "feat: add support for process.env.PORT environment variable",
                         "details": "Support for an environment variable allows the application to be more flexible as it can now run on any available port specified via the process.env.PORT environment variable."
                     }
                   ]
                 }
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
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = httpResponse as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorObject = errorJSON["error"] as? [String: Any],
                   let errorMessage = errorObject["message"] as? String {
                    throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                throw APIError.invalidResponse
            }
            
            print("Received API response. Status code: \(httpResponse.statusCode)")
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(rawResponse)")
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(OpenAIResponse.self, from: data)
            
            guard let responseText = apiResponse.choices.first?.message.content else {
                throw APIError.invalidResponse
            }
            
            guard let jsonData = responseText.data(using: .utf8) else {
                throw APIError.decodingError(NSError(domain: "Encoding", code: 0))
            }
            
            do {
                let wrapper = try decoder.decode(CommitMessagesWrapper.self, from: jsonData)
                return wrapper.commitMessages
            } catch {
                
                do {
                    return try decoder.decode([CommitMessage].self, from: jsonData)
                } catch {
                    print("Error parsing response as structured JSON. Using fallback.")
                    
                    return [
                        CommitMessage(
                            message: "Auto-generated commit",
                            details: responseText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        )
                    ]
                }
            }
        } catch {
            print("API Error: \(error.localizedDescription)")
            throw error
        }
    }
}
    

struct OpenAIResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
}
                         
struct OpenAIChoice: Decodable {
    let message: OpenAIMessage
    let finish_reason: String
    let index: Int
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

struct CommitMessagesWrapper: Decodable {
    let commitMessages: [CommitMessage]
}
