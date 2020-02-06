//
//  CommitResponse.swift
//  gitTest
//
//  Created by Ankur Sehdev on 05/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import Foundation

public struct CommitResponse: Codable {
    public let sha: String?
    public let message : String?
    
    enum CodingKeys: String, CodingKey {
        case sha
        case commit
        case message
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sha = try values.decodeIfPresent(String.self, forKey: .sha)
        let response = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .commit)
        message = try response.decode(String.self, forKey: .message)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var response = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .commit)
        try response.encode(message, forKey: .message)
    }
}
