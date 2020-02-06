//
//  LastCommit.swift
//  gitTest
//
//  Created by Ankur Sehdev on 05/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import Foundation

public struct LastCommit: Codable {
    public let sha: String?
    public let url : String?
    
    enum CodingKeys: String, CodingKey {
           case sha
           case url

       }
       public init(from decoder: Decoder) throws {
           let values = try decoder.container(keyedBy: CodingKeys.self)
           url = try values.decodeIfPresent(String.self, forKey: .url)
           sha = try values.decodeIfPresent(String.self, forKey: .sha)
       }
}
