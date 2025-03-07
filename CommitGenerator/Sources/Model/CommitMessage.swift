//
//  CommitMessage.swift
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

import Foundation

public struct CommitMessage: Codable, CustomStringConvertible {
    public let message: String
    public let details: String
    
    public var description: String {
        return """
        Commit: \(message)
        Details: \(details)
        """
    }
    
    public init(message: String, details: String) {
        self.message = message
        self.details = details
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case details
        case description
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        message = try container.decode(String.self, forKey: .message)
        
        if container.contains(.details) {
            details = try container.decode(String.self, forKey: .details)
        } else if container.contains(.description) {
            details = try container.decode(String.self, forKey: .description)
        } else {
            details = "No details provided"
        }
    }
    
    // Custom encoder implementation to match the decoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(details, forKey: .details)
    }
}
