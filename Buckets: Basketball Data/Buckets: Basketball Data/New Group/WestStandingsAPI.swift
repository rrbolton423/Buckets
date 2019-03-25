//
//  WestStandingsAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/24/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

class WestStandingsAPI {
    var westTeamsArray = [StandingTeam]()
    func getStandings(url: String, completion: @escaping ([StandingTeam]) -> Void) {
        var westTeam: StandingTeam?
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
            let westernConferenceRowSet = json["resultSets"][5]["rowSet"]
            if westernConferenceRowSet.count == 0 {
                if let jsonArray = westernConferenceRowSet.array
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
                        let westTeam = StandingTeam.init(ID: ID, conference: conference, team: team, gamesPlayed: gamesPlayed, wins: wins, losses: losses, winPercentage: winPercentage, homeRecord: homeRecord, awayRecord: awayRecord)
                        westTeamsArray.append(westTeam)
                    }
                }
            } else {
                if let jsonArray = westernConferenceRowSet.array
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
                        westTeam = StandingTeam.init(ID: ID, conference: conference, team: team, gamesPlayed: gamesPlayed, wins: wins, losses: losses, winPercentage: winPercentage, homeRecord: homeRecord, awayRecord: awayRecord)
                        westTeamsArray.append(westTeam!)
                    }
                }
            }
        } catch {
            print(error)
        }
        completion(westTeamsArray)
    }
}
