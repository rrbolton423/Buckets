//
//  PlayerDetailVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import StoreKit

class PlayerDetailVC: UIViewController {
    @IBOutlet weak var headshotImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var jerseyLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var birthdateLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var draftedLabel: UILabel!
    @IBOutlet weak var ppgLabel: UILabel!
    @IBOutlet weak var apgLabel: UILabel!
    @IBOutlet weak var rpgLabel: UILabel!
    
    var teamID: String?
    var playerHeadshotURL: String?
    var playerID: String?
    var playerBirthdateFormatted: String?
    var playerInfoURL: String?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var appLaunches = UserDefaults.standard.integer(forKey: "appLaunches")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        checkForPlayerID()
        fetchPlayer()
        requestAppStoreReview()
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
    }
    
    func checkForPlayerID() {
        if let playerID = self.playerID {
            playerInfoURL = "\(PlayerInfoBaseURL)?\(PlayerID)\(playerID)"
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "Fatal Error", message: "PlayerID Required")
        }
    }
    
    func fetchPlayer() {
        if CheckInternet.connection() {
            activityIndicator.startAnimating()
            let detailPlayerApi = PlayerApi()
            if let playerInfoURL = self.playerInfoURL {
                detailPlayerApi.getPlayers(url: playerInfoURL) { (detailPlayer) in
                    self.showDetail(player: detailPlayer)
                }
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
        }
    }
    
    func showDetail(player: Player) {
        DispatchQueue.main.async {
            self.activityIndicator.removeFromSuperview()
            self.navigationItem.title = player.name
            

            
            if let name = player.name {
                if name == "" {
                    self.nameLabel.text = "N/A"
                } else {
                    self.nameLabel.text = name
                }
            } else {
                self.nameLabel.text = "N/A"
            }
            
            if let teamCity = player.teamCity, let teamName = player.teamName {
                if teamCity == "" || teamName == "" {
                    self.teamLabel.text = "N/A"
                } else {
                    self.teamLabel.text = "\(teamCity) \(teamName)"
                }
            } else {
                self.teamLabel.text = "N/A"
            }
            
            if let jerseyNumber = player.jerseyNumber {
                if jerseyNumber == "" {
                    self.jerseyLabel.text = "N/A"
                } else {
                    self.jerseyLabel.text = "#\(jerseyNumber)"
                }
            } else {
                self.jerseyLabel.text = "N/A"
            }
            
            if let position = player.position {
                if position == "" {
                    self.positionLabel.text = "N/A"
                } else {
                    self.positionLabel.text = position
                }
            } else {
                self.positionLabel.text = "N/A"
            }
            
            if let birthdate = self.playerBirthdateFormatted {
                if birthdate == "" {
                    self.birthdateLabel.text = "N/A"
                } else {
                    self.birthdateLabel.text = "\(birthdate.lowercased().capitalized) (\(self.calcAge(birthday: birthdate)) years)"
                }
            } else {
                self.birthdateLabel.text = "N/A"
            }
            
            if let height = player.height {
                if height == "" {
                    self.heightLabel.text = "N/A"
                } else {
                    let newHeight = height.replacingOccurrences(of: "-", with: " ' ")
                    let lastChar = "\""
                    self.heightLabel.text = "\(newHeight) \(lastChar)"
                }
            } else {
                self.heightLabel.text = "N/A"
            }
            
            if let weight = player.weight {
                if weight == "" {
                    self.weightLabel.text = "N/A"
                } else {
                    self.weightLabel.text = "\(weight) lbs"
                }
            } else {
                self.weightLabel.text = "N/A"
            }
            
            if let school = player.school {
                if school == "" {
                    self.schoolLabel.text = "N/A"
                } else {
                    self.schoolLabel.text = school
                }
            } else {
                self.schoolLabel.text = "N/A"
            }
            
            if let experience = player.experience {
                if experience == "" {
                    self.experienceLabel.text = "N/A"
                } else {
                    if experience == "0" {
                        self.experienceLabel.text = "Rookie"
                    } else if experience == "1" {
                        self.experienceLabel.text = "\(experience) year"
                    } else {
                        self.experienceLabel.text = "\(experience) years"
                    }
                }
            } else {
                self.experienceLabel.text = "N/A"
            }
            
            if let draftYear = player.draftYear, let draftRound = player.draftRound, let draftPick = player.draftNumber {
                if draftYear == "" || draftRound == "" || draftPick == "" {
                    self.draftedLabel.text = "N/A"
                } else {
                    if draftYear == "Undrafted" || draftRound == "Undrafted" || draftPick == "Undrafted" {
                        self.draftedLabel.text = "Undrafted"
                    } else {
                        self.draftedLabel.text = "\(draftYear) / Round \(draftRound) / Pick \(draftPick)"
                    }
                }
            } else {
                self.draftedLabel.text = "N/A"
            }
            
            if let ppg = player.ppg {
                if ppg == "" {
                    self.ppgLabel.text = "N/A"
                } else {
                    let ppg = (ppg as NSString).doubleValue
                    self.ppgLabel.text = String(ppg.rounded(toPlaces: 1))
                }
            } else {
                self.ppgLabel.text = "N/A"
            }
            
            if let apg = player.apg {
                if apg == "" {
                    self.apgLabel.text = "N/A"
                } else {
                    let apg = (apg as NSString).doubleValue
                    self.apgLabel.text = String(apg.rounded(toPlaces: 1))
                }
            } else {
                self.apgLabel.text = "N/A"
            }
            
            if let rpg = player.rpg {
                if rpg == "" {
                    self.rpgLabel.text = "N/A"
                } else {
                    let rpg = (rpg as NSString).doubleValue
                    self.rpgLabel.text = String(rpg.rounded(toPlaces: 1))
                }
            } else {
                self.rpgLabel.text = "N/A"
            }
            
            if let ID = player.ID, let teamID = player.teamID {
                if ID == "" {
                    self.headshotImageView.displayPlaceholderImage()
                } else {
                    if use_real_images == "false" {
                        self.headshotImageView.displayPlaceholderImage()
                    } else {
                        self.playerHeadshotURL = "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/\(teamID)/2018/260x190/\(ID).png"
                        if self.playerHeadshotURL != nil {
                            self.headshotImageView.loadImageUsingCache(withURL: self.playerHeadshotURL ?? "")
                            if self.headshotImageView.image != nil {
                                return
                            } else {
                                self.headshotImageView.displayPlaceholderImage()
                            }
                        }
                    }
                }
            } else {
                self.headshotImageView.displayPlaceholderImage()
            }
        }
    }
    
    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MMM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!
    }
    
    func requestAppStoreReview() {
        if appLaunches == 5 || appLaunches == 25 || appLaunches == 50 {
            SKStoreReviewController.requestReview()
            var appLaunches = UserDefaults.standard.integer(forKey: "appLaunches")
            appLaunches += 1
            UserDefaults.standard.set(appLaunches, forKey: "appLaunches")
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

