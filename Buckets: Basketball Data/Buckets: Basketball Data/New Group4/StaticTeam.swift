//
//  StaticTeam.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation

struct StaticTeam {
    let ID: String?
    let abbreviation: String?
    let name: String?
    let picture: String?
    
    init (dictionary: [String: Any]) {
        self.ID = dictionary["teamID"] as? String ?? ""
        self.abbreviation = dictionary["abbreviation"] as? String ?? ""
        self.name = dictionary["teamName"] as? String ?? ""
        self.picture = dictionary["teamPic"] as? String ?? ""
    }
}
