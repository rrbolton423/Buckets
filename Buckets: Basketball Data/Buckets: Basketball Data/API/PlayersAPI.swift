//
//  PlayersAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

class PlayersApi {
    func getPlayers(url: String, completion: @escaping ([Players]?, Error?) -> Void) {
        var resultArray = [Players]()
        var ID: String?
        var fullName: String?
        var firstName: String?
        var lastName: String?
        var birthdate: String?
        var jerseyNumber: String?
        var position: String?
        var teamID: String?
        var fullNameArr: [String]?
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
                            fullName = "N/A"
                            firstName = "N/A"
                            lastName = "N/A"
                            birthdate = "N/A"
                            jerseyNumber = "N/A"
                            position = "N/A"
                            teamID = "N/A"
                            let player = Players(ID: ID, fullName: fullName, firstName: firstName, lastName: lastName, birthdate: birthdate, jerseyNumber: jerseyNumber, position: position, teamID: teamID)
                            resultArray.append(player)
                        }
                    }
                } else {
                    if let jsonArray = rowSet.array
                    {
                        for item in jsonArray
                        {
                            teamID = item.arrayValue[0].stringValue
                            fullName = item.arrayValue[3].stringValue
                            fullNameArr = fullName?.components(separatedBy: " ")
                            firstName = fullNameArr?[0]
                            if fullNameArr?.count == 1 {
                                lastName = fullNameArr?[0]
                            } else {
                                lastName = fullNameArr?[1] ?? ""
                            }
                            birthdate = item.arrayValue[8].stringValue
                            jerseyNumber = item.arrayValue[5].stringValue
                            position = item.arrayValue[6].stringValue
                            ID = item.arrayValue[13].stringValue
                            let player = Players(ID: ID, fullName: fullName, firstName: firstName, lastName: lastName, birthdate: birthdate, jerseyNumber: jerseyNumber, position: position, teamID: teamID)
                            resultArray.append(player)
                        }
                    }
                }
                completion(resultArray, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }.resume()
    }
}
