//
//  RejectPullRequestResponse.swift
//  gitTest
//
//  Created by Ankur Sehdev on 08/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import Foundation

public struct RejectPullRequestResponse: Codable {
    
    public let sha : String?
    public let title : String?
    public let body : String?
    public let state : String?
    public let merged : Bool?
    
    enum CodingKeys: String, CodingKey {
        case sha
        case title
        case body
        case state
        case merged
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sha = try values.decodeIfPresent(String.self, forKey: .sha)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        body = try values.decodeIfPresent(String.self, forKey: .body)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        merged = try values.decodeIfPresent(Bool.self, forKey: .merged)
    }
    
    
}
