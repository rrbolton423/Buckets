//
//  StaticTeam.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation

class StaticTeam: NSObject, NSCoding {
    
    let ID: String?
    let abbreviation: String?
    let name: String?
    let picture: String?
    
    init?(dictionary: [String: Any]) {
        self.ID = dictionary["teamID"] as? String ?? ""
        self.abbreviation = dictionary["abbreviation"] as? String ?? ""
        self.name = dictionary["teamName"] as? String ?? ""
        self.picture = dictionary["teamPic"] as? String ?? ""
    }
    
//    init(ID:String,abbreviation:String,name:String,picture:String)
//    {
//        self.ID = ID
//        self.abbreviation = abbreviation
//        self.name = name
//        self.picture = picture
//    }
    
    //TO SAVE IN NSUSERDEFAULTS
    
    required init(coder aDecoder: NSCoder){
        self.ID = aDecoder.decodeObject(forKey: "teamID") as? String
        self.abbreviation = aDecoder.decodeObject(forKey: "abbreviation") as? String
        self.name = aDecoder.decodeObject(forKey: "teamName") as? String
        self.picture = aDecoder.decodeObject(forKey: "teamPic") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.ID,forKey:"teamID")
        aCoder.encode(self.abbreviation,forKey:"abbreviation")
        aCoder.encode(self.name,forKey:"teamName")
        aCoder.encode(self.picture,forKey:"teamPic")
    }

}

class DataStore {
    static let sharedInstance = DataStore()
    private init() {}
    var favoriteTeams: [StaticTeam] = []
}
