//
//  BranchReponse.swift
//  gitTest
//
//  Created by Ankur Sehdev on 05/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import Foundation

public struct BranchResponse: Codable {
    public let name: String?
    public let protected : Bool?
    public let protectionUrl : String?
    public let commit : LastCommit?

//    public let tokenType: String
//    public let scope: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case protected = "protected"
        case protectionUrl = "protection_url"
        case commit

//        case tokenType = "token_type"
//        case scope = "scope"
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        protected = try values.decodeIfPresent(Bool.self, forKey: .protected)
        protectionUrl = try values.decodeIfPresent(String.self, forKey: .protectionUrl)
        commit = try values.decodeIfPresent(LastCommit.self, forKey: .commit)
    }
}
