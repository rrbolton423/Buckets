//
//  EastStandingsAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/24/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

class EastStandingsAPI {
    var eastTeamsArray = [StandingTeam]()
    func getStandings(url: String, completion: @escaping ([StandingTeam]?, Error?) -> Void) {
        var eastTeam: StandingTeam?
        var ID: String?
        var conference: String?
        var team: String?
        var gamesPlayed: String?
        var wins: String?
        var losses: String?
        var winPercentage: String?
        var homeRecord: String?
        var awayRecord: String?
        guard let url = URL(string: url) else { return }
        do {
            let data = try Data(contentsOf: url)
            let json = try JSON(data: data)
            _ = json["resultSets"][0]["headers"]
            let easternConferenceRowSet = json["resultSets"][4]["rowSet"]
            if easternConferenceRowSet.count == 0 {
                if let jsonArray = easternConferenceRowSet.array
                {
                    for _ in jsonArray
                    {
                        ID = "N/A"
                        conference = "N/A"
                        team = "N/A"
                        gamesPlayed = "N/A"
                        wins = "N/A"
                        losses = "N/A"
                        winPercentage = "N/A"
                        homeRecord = "N/A"
                        awayRecord = "N/A"
                        let eastTeam = StandingTeam.init(ID: ID, conference: conference, team: team, gamesPlayed: gamesPlayed, wins: wins, losses: losses, winPercentage: winPercentage, homeRecord: homeRecord, awayRecord: awayRecord)
                        eastTeamsArray.append(eastTeam)
                    }
                }
            } else {
                if let jsonArray = easternConferenceRowSet.array
                {
                    for item in jsonArray
                    {
                        ID = item.arrayValue[0].stringValue
                        conference = item.arrayValue[4].stringValue
                        team = item.arrayValue[5].stringValue
                        gamesPlayed = item.arrayValue[6].stringValue
                        wins = item.arrayValue[7].stringValue
                        losses = item.arrayValue[8].stringValue
                        winPercentage = item.arrayValue[9].stringValue
                        homeRecord = item.arrayValue[10].stringValue
                        awayRecord = item.arrayValue[11].stringValue
                        eastTeam = StandingTeam.init(ID: ID, conference: conference, team: team, gamesPlayed: gamesPlayed, wins: wins, losses: losses, winPercentage: winPercentage, homeRecord: homeRecord, awayRecord: awayRecord)
                        eastTeamsArray.append(eastTeam!)
                    }
                }
            }
        } catch {
            print(error)
            completion(nil, error)
        }
        completion(eastTeamsArray, nil)
    }
}