//
//  TodaysGamesAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/24/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

class TodaysGamesAPI {
    func getStandings(url: String, completion: @escaping (DetailTeam) -> Void) {
        var detailTeam: DetailTeam?
        let ID: String?
        let conference: String?
        let team: String?
        let wins: String?
        let losses: String?
        let winPercentage: String?
        let homeRecord: String?
        let AwayRecord: String?
        
        
//        guard let url = URL(string: url) else { return }
//        //do {
//        let data = try Data(contentsOf: url)
//        let json = try JSON(data: data)
//        _ = json["resultSets"][0]["headers"]
//        let rowSet = json["resultSets"][0]["rowSet"]
//        var teamInfo: JSON?
        
//        print(rowSet)
        
        //            if rowSet.count == 0 {
        //                ID = "N/A"
        //                city = "N/A"
        //                name = "N/A"
        //                conference = "N/A"
        //                division = "N/A"
        //                wins = "N/A"
        //                losses = "N/A"
        //                conferenceRank = "N/A"
        //                divisionRank = "N/A"
        //                yearFounded = "N/A"
        //                detailTeam = DetailTeam(ID: ID, city: city, name: name, conference: conference, division: division, wins: wins, losses: losses, conferenceRank: conferenceRank, divisionRank: divisionRank, yearFounded: yearFounded)
        //            } else {
        //                for (_, teamJson):(String, JSON) in rowSet {
        //                    teamInfo = teamJson
        //                    break
        //                }
        //                ID = teamInfo?.arrayValue[0].stringValue
        //                city = teamInfo?.arrayValue[2].stringValue
        //                name = teamInfo?.arrayValue[3].stringValue
        //                conference = teamInfo?.arrayValue[5].stringValue
        //                division = teamInfo?.arrayValue[6].stringValue
        //                wins = teamInfo?.arrayValue[8].stringValue
        //                losses = teamInfo?.arrayValue[9].stringValue
        //                conferenceRank = teamInfo?.arrayValue[11].stringValue
        //                divisionRank = teamInfo?.arrayValue[12].stringValue
        //                yearFounded = teamInfo?.arrayValue[13].stringValue
        //                detailTeam = DetailTeam(ID: ID, city: city, name: name, conference: conference, division: division, wins: wins, losses: losses, conferenceRank: conferenceRank, divisionRank: divisionRank, yearFounded: yearFounded)
        //            }
        //        } catch {
        //            print(error)
        //        }
        //        if let team = detailTeam {
        //            completion(team)
        //        }
    }
}

//func dataLoaded(data:Data?,response:URLResponse?,error:Error?){
//    if let standingsDetailData = data{
//        let decoder = JSONDecoder()
//        do {
//            let jsondata = try decoder.decode(Initial.self, from: standingsDetailData)
//            var i = 0
//            var j = 0
//            standingData = jsondata.records!
//            for _ in standingData{
//                for _ in standingData[i].teamRecords {
//                    let teamName = standingData[i].teamRecords[j].team.name
//                    let gP = standingData[i].teamRecords[j].gamesPlayed
//                    let w = standingData[i].teamRecords[j].leagueRecord.wins
//                    let l = standingData[i].teamRecords[j].leagueRecord.losses
//                    let oT = standingData[i].teamRecords[j].leagueRecord.ot
//                    let p = standingData[i].teamRecords[j].points
//                    gamesPlayed.append(gP)
//                    wins.append(w)
//                    loses.append(l)
//                    overTime.append(oT!)
//                    points.append(p)
//                    teams.append(teamName)
//                    j+=1
//                    if(j >= standingData[i].teamRecords.count) {
//                        j = 0
//                    }
//                }
//                i+=1
//            }
//            DispatchQueue.main.async{
//                self.tableView.reloadData()
//                self.activityIndicator.removeFromSuperview()
//            }
//        }catch let error{
//            print(error)
//        }
//    }else{
//        print(error!)
//    }
//}
//

