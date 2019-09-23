//
//  TeamAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

class TeamAPI {
    func getTeamInfo(url: String, completion: @escaping (DetailTeam?, Error?) -> Void) {
        var detailTeam: DetailTeam?
        let ID: String?
        let city: String?
        let name: String?
        let conference: String?
        let division: String?
        let wins: String?
        let losses: String?
        let conferenceRank: String?
        let divisionRank: String?
        let yearFounded: String?
        guard let url = URL(string: url) else { return }
        do {
            let data = try Data(contentsOf: url)
            let json = try JSON(data: data)
            _ = json["resultSets"][0]["headers"]
            let rowSet = json["resultSets"][0]["rowSet"]
            var teamInfo: JSON?
            if rowSet.count == 0 {
                ID = "N/A"
                city = "N/A"
                name = "N/A"
                conference = "N/A"
                division = "N/A"
                wins = "N/A"
                losses = "N/A"
                conferenceRank = "N/A"
                divisionRank = "N/A"
                yearFounded = "N/A"
                detailTeam = DetailTeam(ID: ID, city: city, name: name, conference: conference, division: division, wins: wins, losses: losses, conferenceRank: conferenceRank, divisionRank: divisionRank, yearFounded: yearFounded)
            } else {
                for (_, teamJson):(String, JSON) in rowSet {
                    teamInfo = teamJson
                    break
                }
                ID = teamInfo?.arrayValue[0].stringValue
                city = teamInfo?.arrayValue[2].stringValue
                name = teamInfo?.arrayValue[3].stringValue
                conference = teamInfo?.arrayValue[5].stringValue
                division = teamInfo?.arrayValue[6].stringValue
                wins = teamInfo?.arrayValue[8].stringValue
                losses = teamInfo?.arrayValue[9].stringValue
                conferenceRank = teamInfo?.arrayValue[11].stringValue
                divisionRank = teamInfo?.arrayValue[12].stringValue
                yearFounded = teamInfo?.arrayValue[13].stringValue
                detailTeam = DetailTeam(ID: ID, city: city, name: name, conference: conference, division: division, wins: wins, losses: losses, conferenceRank: conferenceRank, divisionRank: divisionRank, yearFounded: yearFounded)
            }
        } catch {
            print(error)
            completion(nil, error)
        }
        if let team = detailTeam {
            completion(team, nil)
        }
    }
}

