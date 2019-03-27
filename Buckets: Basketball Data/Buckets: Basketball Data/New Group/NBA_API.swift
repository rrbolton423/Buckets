//
//  TodaysGamesAPI.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/24/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import SwiftyJSON

struct NBA {
    var games: [Game]
    var numberOfGames: Int
}

struct Game {
    var arena: String
    var homeTeamName: String
    var homeTeamScore: String
    var awayTeamName: String
    var awayTeamScore: String
    var quarter: String
    var time: String
}

extension Game: Equatable {}

func ==(lhs: Game, rhs: Game) -> Bool {
    let areEqual = lhs.awayTeamName == rhs.awayTeamName &&
        lhs.homeTeamName == rhs.homeTeamName
    
    return areEqual
}

class NBA_API {
    
    var gamesArray = [Game]()
    let baseURL = "http://data.nba.com/data/5s/json/cms/noseason/scoreboard/%@/games.json"
    
    func getTodaysDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yMMdd"
        let result = formatter.string(from: date)
        return result
    }
    
    func getScores(date: String, success: @escaping ([Game]) -> Void) {
        var url = URL(string: String(format: baseURL, date))
        url?.removeAllCachedResourceValues()
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession.init(configuration: config)
        session.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                if let games = self.parseJSON(data: data! as NSData) {
                    let arr = games.removingDuplicates()
                    success(arr)
                } else {
                    success([])
                }
            }
            }.resume()
    }
    
    func parseJSON(data: NSData) -> [Game]? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try JSONSerialization.jsonObject(with: data as Data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var jsonData = json["sports_content"] as! [String:Any]
        var games = jsonData["games"] as! [String:Any]
        let gameList = games["game"] as? [[String:Any]]
        
        for game in gameList! {
            let g = game as NSDictionary
            let home = g["home"] as! NSDictionary
            let away = g["visitor"] as! NSDictionary
            let gameStatus = g["period_time"] as! NSDictionary
            
            let arena = g["arena"]! as! String
            let awayTeamName = away["abbreviation"]! as! String
            let awayTeamScore = away["score"]! as! String
            let homeTeamName = home["abbreviation"]! as! String
            let homeTeamScore = home["score"]! as! String
            let quarter = gameStatus["period_status"]! as! String
            let time = gameStatus["game_clock"]! as! String
            
            let gameInfo = Game(
                arena: arena,
                homeTeamName: homeTeamName,
                homeTeamScore: homeTeamScore,
                awayTeamName: awayTeamName,
                awayTeamScore: awayTeamScore,
                quarter: quarter,
                time: time
            )
            gamesArray.append(gameInfo)
        }
        print("CALLED IN NBA_API() \(gamesArray)")
        return gamesArray
    }
}
