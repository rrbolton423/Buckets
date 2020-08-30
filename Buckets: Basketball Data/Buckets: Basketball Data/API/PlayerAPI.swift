//
//  PlayerAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

class PlayerApi {
    func getPlayers(url: String, completion: @escaping (Player?, Error?) -> Void) {
        var player: Player?
        var ID: String?
        var teamID: String?
        var name: String?
        var teamCity: String?
        var teamName: String?
        var jerseyNumber: String?
        var position: String?
        var birthdate: String?
        var height: String?
        var weight: String?
        var school: String?
        var experience: String?
        var draftYear: String?
        var draftRound: String?
        var draftNumber: String?
        var ppg: String?
        var apg: String?
        var rpg: String?
        guard let headerUrl = URL(string: url) else { return }
        var request = URLRequest(url: headerUrl)
        request.httpMethod = "GET"
        request.setValue("stats.nba.com", forHTTPHeaderField:"Referer")
        request.setValue("stats", forHTTPHeaderField:"x-nba-stats-origin")
        request.setValue("true", forHTTPHeaderField:"x-nba-stats-token")
        request.timeoutInterval = 60.0
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { print(error!); return }
            guard let data = data else { print("No data"); return }
            do {
                let json = try JSON(data: data)
                _ = json["resultSets"][0]["headers"]
                let rowSet = json["resultSets"][0]["rowSet"]
                if rowSet.count == 0 {
                    if let jsonArray = rowSet.array
                    {
                        for _ in jsonArray
                        {
                            ID = "N/A"
                            teamID = "N/A"
                            name = "N/A"
                            teamName = "N/A"
                            teamCity = "N/A"
                            birthdate = "N/A"
                            school = "N/A"
                            height = "N/A"
                            weight = "N/A"
                            experience = "N/A"
                            jerseyNumber = "N/A"
                            position = "N/A"
                            draftYear = "N/A"
                            draftRound = "N/A"
                            draftNumber = "N/A"
                        }
                    }
                } else {
                    if let jsonArray = rowSet.array
                    {
                        for item in jsonArray
                        {
                            ID = item.arrayValue[0].stringValue
                            teamID = item.arrayValue[17].stringValue
                            name = item.arrayValue[3].stringValue
                            teamCity = item.arrayValue[21].stringValue
                            teamName = item.arrayValue[18].stringValue
                            jerseyNumber = item.arrayValue[14].stringValue
                            position = item.arrayValue[15].stringValue
                            birthdate = item.arrayValue[7].string
                            height = item.arrayValue[11].stringValue
                            weight = item.arrayValue[12].stringValue
                            school = item.arrayValue[8].stringValue
                            experience = item.arrayValue[13].stringValue
                            draftYear = item.arrayValue[28].stringValue
                            draftRound = item.arrayValue[29].stringValue
                            draftNumber = item.arrayValue[30].stringValue
                        }
                    }
                }
                let rowSet2 = json["resultSets"][1]["rowSet"]
                if rowSet2.count == 0 {
                    ppg = "N/A"
                    apg = "N/A"
                    rpg = "N/A"
                    player = Player(ID: ID, teamID: teamID, name: name, teamCity: teamCity, teamName: teamName, jerseyNumber: jerseyNumber, position: position, birthdate: birthdate, height: height, weight: weight, school: school, experience: experience, draftYear: draftYear, draftRound: draftRound, draftNumber: draftNumber, ppg: ppg, apg: apg, rpg: rpg)
                } else {
                    if let jsonArray2 = rowSet2.array
                    {
                        for item in jsonArray2
                        {
                            ppg = item.arrayValue[3].stringValue
                            apg = item.arrayValue[4].stringValue
                            rpg = item.arrayValue[5].stringValue
                            player = Player(ID: ID, teamID: teamID, name: name, teamCity: teamCity, teamName: teamName, jerseyNumber: jerseyNumber, position: position, birthdate: birthdate, height: height, weight: weight, school: school, experience: experience, draftYear: draftYear, draftRound: draftRound, draftNumber: draftNumber, ppg: ppg, apg: apg, rpg: rpg)
                        }
                    }
                }
            } catch {
                print(error)
                completion(nil, error)
            }
            if let player = player {
                completion(player, nil)
            }
        }.resume()
    }
}
