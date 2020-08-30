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
                let isGameActivated = game["isGameActivated"].boolValue 
                let gameURL = game["gameUrlCode"].rawString() ?? ""
                let arena = game["arena"]["name"].rawString() ?? ""
                let awayTeamName = game["vTeam"]["triCode"].rawString() ?? ""
                let awayTeamScore = game["vTeam"]["score"].rawString() ?? ""
                let homeTeamName = game["hTeam"]["triCode"].rawString() ?? ""
                let homeTeamScore = game["hTeam"]["score"].rawString() ?? ""
                let startTimeEastern = game["startTimeEastern"].rawString() ?? ""
                var quarter = game["period"]["current"].rawString() ?? ""
                let isHalftime = game["period"]["isHalftime"].boolValue 
                if (isHalftime == true) {
                    quarter = "Halftime"
                } else {
                    quarter = "Q\(quarter)"
                    if quarter == "" || quarter == "Q0" {
                        quarter = startTimeEastern
                    }
                }
                if (isGameActivated == false && quarter == "Q4") {
                    quarter = "Final"
                }
                let time = game["clock"].rawString() ?? ""
                let yesterdaysGame = Game.init(gameURL: gameURL, arena: arena, homeTeamName: homeTeamName, homeTeamScore: homeTeamScore, awayTeamName: awayTeamName, awayTeamScore: awayTeamScore, quarter: quarter, time: time)
                yesterdaysGamesArray.append(yesterdaysGame)
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
                let isGameActivated = game["isGameActivated"].boolValue 
                let gameURL = game["gameUrlCode"].rawString() ?? ""
                let arena = game["arena"]["name"].rawString() ?? ""
                let awayTeamName = game["vTeam"]["triCode"].rawString() ?? ""
                let awayTeamScore = game["vTeam"]["score"].rawString() ?? ""
                let homeTeamName = game["hTeam"]["triCode"].rawString() ?? ""
                let homeTeamScore = game["hTeam"]["score"].rawString() ?? ""
                let startTimeEastern = game["startTimeEastern"].rawString() ?? ""
                var quarter = game["period"]["current"].rawString() ?? ""
                let isHalftime = game["period"]["isHalftime"].boolValue 
                if (isHalftime == true) {
                    quarter = "Halftime"
                } else {
                    quarter = "Q\(quarter)"
                    if quarter == "" || quarter == "Q0" {
                        quarter = startTimeEastern
                    }
                }
                if (isGameActivated == false && quarter == "Q4") {
                    quarter = "Final"
                }
                let time = game["clock"].rawString() ?? ""
                let todaysGame = Game.init(gameURL: gameURL, arena: arena, homeTeamName: homeTeamName, homeTeamScore: homeTeamScore, awayTeamName: awayTeamName, awayTeamScore: awayTeamScore, quarter: quarter, time: time)
                todaysGamesArray.append(todaysGame)
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
