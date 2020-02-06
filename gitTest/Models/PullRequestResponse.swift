//
//  PullRequestResponse.swift
//  gitTest
//
//  Created by Ankur Sehdev on 06/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import Foundation

public struct PullRequestResponse: Codable {
    public let number: Int?
    public let title : String?
    public let state : String?
    public let body : String?

    enum CodingKeys: String, CodingKey {
        case number
        case title
        case state
        case body
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        number = try values.decodeIfPresent(Int.self, forKey: .number)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        body = try values.decodeIfPresent(String.self, forKey: .body)
    }
}
