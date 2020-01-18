//
//  Constants.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//
import Foundation

var imageCache = NSCache<NSString, AnyObject>()
var TeamInfoBaseURL = "http://stats.nba.com/stats/teaminfocommon/"
var TeamRosterBaseURL = "https://stats.nba.com/stats/commonteamroster"
var PlayerInfoBaseURL = "https://stats.nba.com/stats/commonplayerinfo"
var Season = "Season=2019-20"
var TeamID = "TeamID="
var PlayerID = "PlayerID="
var LeagueID = "LeagueID=00"
var SeasonType = "SeasonType=Regular+Season"
var IsOnlyCurrentSeason = "IsOnlyCurrentSeason=1"
var PictureYear = "2019"
var ScoreBoardURL = "http://data.nba.com/data/5s/json/cms/noseason/scoreboard/%@/games.json"
var StandingsURL = "https://stats.nba.com/stats/scoreboardV2?DayOffset=0&LeagueID=00&gameDate="
