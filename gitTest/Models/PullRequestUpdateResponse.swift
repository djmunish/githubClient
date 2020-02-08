//
//  PullRequestUpdateResponse.swift
//  gitTest
//
//  Created by Ankur Sehdev on 07/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import Foundation

public struct PullRequestUpdateResponse: Codable {
    public let sha : String?
    public let message : String?
    public let merged : Bool?

    enum CodingKeys: String, CodingKey {
        case sha
        case message
        case merged
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sha = try values.decodeIfPresent(String.self, forKey: .sha)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        merged = try values.decodeIfPresent(Bool.self, forKey: .merged)
    }
}
