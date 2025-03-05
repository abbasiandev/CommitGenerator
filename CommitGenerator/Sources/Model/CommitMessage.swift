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
    
    public init(message: String, description: String) {
        self.message = message
        self.details = description
    }
}
