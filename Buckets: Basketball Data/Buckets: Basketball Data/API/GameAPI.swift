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
    func getGames(yesterdaysDate: String, todaysDate: String, url: String, tomorrowsDate: String, completion: @escaping ([[Game]]) -> Void) {
        var resultArray = [[Game]]()
        var yesterdaysGamesArray = [Game]()
        var todaysGamesArray = [Game]()
        var tomorrowsGamesArray = [Game]()
        let yesterdaysUrl = URL(string: String(format: url, "20181225"))
        guard let unwrappedYesterdaysUrl = yesterdaysUrl else { return }
        do {
            let data = try Data(contentsOf: unwrappedYesterdaysUrl)
            let json = try JSON(data: data)
            let jsonData = json["sports_content"].dictionaryObject
            let games = jsonData?["games"] as! [String:Any]
            let gameList = (games["game"] as? [[String:Any]])!
            for game in gameList
            {
                let g = game as NSDictionary
                let home = g["home"] as! NSDictionary
                let away = g["visitor"] as! NSDictionary
                let gameStatus = g["period_time"] as! NSDictionary
                
                let gameURL = g["game_url"]! as! String
                let arena = g["arena"]! as! String
                let awayTeamName = away["abbreviation"]! as! String
                let awayTeamScore = away["score"]! as! String
                let homeTeamName = home["abbreviation"]! as! String
                let homeTeamScore = home["score"]! as! String
                let quarter = gameStatus["period_status"]! as! String
                let time = gameStatus["game_clock"]! as! String
                let game = Game.init(gameURL: gameURL, arena: arena, homeTeamName: homeTeamName, homeTeamScore: homeTeamScore, awayTeamName: awayTeamName, awayTeamScore: awayTeamScore, quarter: quarter, time: time)
                yesterdaysGamesArray.append(game)
            }
        } catch {
            print(error)
        }
        let todaysUrl = URL(string: String(format: url, "20181226"))
        guard let unwrappedTodaysUrl = todaysUrl else { return }
        do {
            let data = try Data(contentsOf: unwrappedTodaysUrl)
            let json = try JSON(data: data)
            let jsonData = json["sports_content"].dictionaryObject
            let games = jsonData?["games"] as! [String:Any]
            let gameList = (games["game"] as? [[String:Any]])!
            for game in gameList
            {
                let g = game as NSDictionary
                let home = g["home"] as! NSDictionary
                let away = g["visitor"] as! NSDictionary
                let gameStatus = g["period_time"] as! NSDictionary
                let gameURL = g["game_url"]! as! String
                let arena = g["arena"]! as! String
                let awayTeamName = away["abbreviation"]! as! String
                let awayTeamScore = away["score"]! as! String
                let homeTeamName = home["abbreviation"]! as! String
                let homeTeamScore = home["score"]! as! String
                let quarter = gameStatus["period_status"]! as! String
                let time = gameStatus["game_clock"]! as! String
                let game = Game.init(gameURL: gameURL, arena: arena, homeTeamName: homeTeamName, homeTeamScore: homeTeamScore, awayTeamName: awayTeamName, awayTeamScore: awayTeamScore, quarter: quarter, time: time)
                todaysGamesArray.append(game)
            }
        } catch {
            print(error)
        }
        let tomorrowsUrl = URL(string: String(format: url, "20181227"))
        guard let unwrappedTomorrowsUrl = tomorrowsUrl else { return }
        do {
            let data = try Data(contentsOf: unwrappedTomorrowsUrl)
            let json = try JSON(data: data)
            let jsonData = json["sports_content"].dictionaryObject
            let games = jsonData?["games"] as! [String:Any]
            let gameList = (games["game"] as? [[String:Any]])!
            for game in gameList
            {
                let g = game as NSDictionary
                let home = g["home"] as! NSDictionary
                let away = g["visitor"] as! NSDictionary
                let gameStatus = g["period_time"] as! NSDictionary
                let gameURL = g["game_url"]! as! String
                let arena = g["arena"]! as! String
                let awayTeamName = away["abbreviation"]! as! String
                let awayTeamScore = away["score"]! as! String
                let homeTeamName = home["abbreviation"]! as! String
                let homeTeamScore = home["score"]! as! String
                let quarter = gameStatus["period_status"]! as! String
                let time = gameStatus["game_clock"]! as! String
                let game = Game.init(gameURL: gameURL, arena: arena, homeTeamName: homeTeamName, homeTeamScore: homeTeamScore, awayTeamName: awayTeamName, awayTeamScore: awayTeamScore, quarter: quarter, time: time)
                tomorrowsGamesArray.append(game)
            }
        } catch {
            print(error)
        }
        resultArray = [yesterdaysGamesArray, todaysGamesArray, tomorrowsGamesArray]
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
