//
//  GameAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/27/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

class GameAPI {
    func getGames(yesterdaysDate: String, todaysDate: String, url: String, completion: @escaping ([[Game]]) -> Void) {
        var resultArray = [[Game]]()
        var yesterdaysGamesArray = [Game]()
        var todaysGamesArray = [Game]()
        let yesterdaysUrl = URL(string: String(format: url, yesterdaysDate))
        guard let unwrappedYesterdaysUrl = yesterdaysUrl else { return }
        do {
            let data = try Data(contentsOf: unwrappedYesterdaysUrl)
            let json = try JSON(data: data)
            let gamesArray = json["games"].arrayValue
            for game in gamesArray
            {
                let isGameActivated = game["isGameActivated"].stringValue
                let gameURL = game["gameUrlCode"].stringValue
                let arena = game["arena"]["name"].stringValue
                let awayTeamName = game["vTeam"]["triCode"].stringValue
                let awayTeamScore = game["vTeam"]["score"].stringValue
                let homeTeamName = game["hTeam"]["triCode"].stringValue
                let homeTeamScore = game["hTeam"]["score"].stringValue
                let quarter = game["period"]["current"].stringValue
                let startTime = game["startTimeEastern"].stringValue
                let isHalftime = game["period"]["isHalftime"].stringValue
                let game = Game.init(isHalftime: isHalftime, isGameActivated: isGameActivated, gameURL: gameURL, arena: arena, homeTeamName: homeTeamName, homeTeamScore: homeTeamScore, awayTeamName: awayTeamName, awayTeamScore: awayTeamScore, quarter: quarter, tipOffTime: startTime)
                yesterdaysGamesArray.append(game)
            }
        } catch {
            print(error)
        }
        let todaysUrl = URL(string: String(format: url, todaysDate))
        guard let unwrappedTodaysUrl = todaysUrl else { return }
        do {
            let data = try Data(contentsOf: unwrappedTodaysUrl)
            let json = try JSON(data: data)
            let gamesArray = json["games"].arrayValue
            for game in gamesArray
            {
                let isGameActivated = game["isGameActivated"].stringValue
                let gameURL = game["gameUrlCode"].stringValue
                let arena = game["arena"]["name"].stringValue
                let awayTeamName = game["vTeam"]["triCode"].stringValue
                let awayTeamScore = game["vTeam"]["score"].stringValue
                let homeTeamName = game["hTeam"]["triCode"].stringValue
                let homeTeamScore = game["hTeam"]["score"].stringValue
                let quarter = game["period"]["current"].stringValue
                let startTime = game["startTimeEastern"].stringValue
                let isHalftime = game["period"]["isHalftime"].stringValue
                let game = Game.init(isHalftime: isHalftime, isGameActivated: isGameActivated, gameURL: gameURL, arena: arena, homeTeamName: homeTeamName, homeTeamScore: homeTeamScore, awayTeamName: awayTeamName, awayTeamScore: awayTeamScore, quarter: quarter, tipOffTime: startTime)
                todaysGamesArray.append(game)
            }
        } catch {
            print(error)
        }
        resultArray = [todaysGamesArray, yesterdaysGamesArray]
        completion(resultArray)
    }
    
    func getTodaysDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yMMdd"
        let result = formatter.string(from: date)
        return result
    }
    
    func getYesterdaysDate() -> String {
        let yesterdaysDate = NSCalendar.current.date(byAdding: .day, value: -1, to: NSDate() as Date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yMMdd"
        let aDayBefore:String = dateFormatter.string(from: yesterdaysDate!)
        return aDayBefore
    }
    
    func getTomorrowsDate() -> String {
        let yesterdaysDate = NSCalendar.current.date(byAdding: .day, value: +1, to: NSDate() as Date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yMMdd"
        let aDayBefore:String = dateFormatter.string(from: yesterdaysDate!)
        return aDayBefore
    }
}
