//
//  TeamDetailVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import SwiftyJSON

class TeamDetailVC: UIViewController {
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamYearFoundedLabel: UILabel!
    @IBOutlet weak var teamCityLabel: UILabel!
    @IBOutlet weak var teamConferenceLabel: UILabel!
    @IBOutlet weak var teamDivisionLabel: UILabel!
    @IBOutlet weak var teamRecordLabel: UILabel!
    @IBOutlet weak var teamConferenceRankLabel: UILabel!
    @IBOutlet weak var teamDivisionRankLabel: UILabel!
    
    var staticTeam: StaticTeam?
    var teamToPass: DetailTeam?
    var teamID: String?
    var baseURL: String?
    var detailImage: UIImage?
    var detailURL: String?
    var teamInfoURL: String?
    var teamImage: UIImage?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        checkForTeamID()
        fetchRoster()
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
    }
    
    func checkForTeamID() {
        if let teamID = self.staticTeam?.ID {
            teamInfoURL = "\(TeamInfoBaseURL)?\(Season)&\(TeamID)\(teamID)&\(LeagueID)&\(SeasonType)"
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "Fatal Error", message: "TeamID Required")
        }
    }
    
    func fetchRoster() {
        if CheckInternet.connection() {
            activityIndicator.startAnimating()
            let teamApi = TeamAPI()
            if let teamInfoURL = self.teamInfoURL {
                teamApi.getTeamInfo(url: teamInfoURL) { (detailTeam) in
                    self.showInfoDetail(team: detailTeam)
                    self.teamToPass = detailTeam
                }
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
        }
    }
    
    func showInfoDetail(team: DetailTeam?) {
        DispatchQueue.main.async {
            self.activityIndicator.removeFromSuperview()
            if let city = team?.city, let name = team?.name {
                if name == "" {
                    self.teamNameLabel.text = "N/A"
                } else {
                    self.navigationItem.title = "\(city) \(name)"
                    self.teamNameLabel.text = "\(city) \(name)"
                    switch name {
                    case "Nets": self.teamImage = UIImage(named: "bkn.jpg")
                    case "Hawks": self.teamImage = UIImage(named: "atl.jpg")
                    case "Celtics": self.teamImage = UIImage(named: "bos.jpg")
                    case "Hornets": self.teamImage = UIImage(named: "cha.jpg")
                    case "Bulls": self.teamImage = UIImage(named: "chi.jpg")
                    case "Cavaliers": self.teamImage = UIImage(named: "cle.jpg")
                    case "Mavericks": self.teamImage = UIImage(named: "dal.jpg")
                    case "Nuggets": self.teamImage = UIImage(named: "den.jpg")
                    case "Pistons": self.teamImage = UIImage(named: "det.jpg")
                    case "Warriors": self.teamImage = UIImage(named: "gsw.jpg")
                    case "Rockets": self.teamImage = UIImage(named: "hou.jpg")
                    case "Pacers": self.teamImage = UIImage(named: "ind.jpg")
                    case "Clippers": self.teamImage = UIImage(named: "lac.jpg")
                    case "Lakers": self.teamImage = UIImage(named: "lal.jpg")
                    case "Grizzlies": self.teamImage = UIImage(named: "mem.jpg")
                    case "Heat": self.teamImage = UIImage(named: "mia.jpg")
                    case "Bucks": self.teamImage = UIImage(named: "mil.jpg")
                    case "Timberwolves": self.teamImage = UIImage(named: "min.jpg")
                    case "Pelicans": self.teamImage = UIImage(named: "nop.jpg")
                    case "Knicks": self.teamImage = UIImage(named: "nyk.jpg")
                    case "Thunder": self.teamImage = UIImage(named: "okc.jpg")
                    case "Magic": self.teamImage = UIImage(named: "orl.jpg")
                    case "76ers": self.teamImage = UIImage(named: "phi.jpg")
                    case "Suns": self.teamImage = UIImage(named: "phx.jpg")
                    case "Trail Blazers": self.teamImage = UIImage(named: "por.jpg")
                    case "Kings": self.teamImage = UIImage(named: "sac.jpg")
                    case "Spurs": self.teamImage = UIImage(named: "sas.jpg")
                    case "Raptors": self.teamImage = UIImage(named: "tor.jpg")
                    case "Jazz": self.teamImage = UIImage(named: "uta.jpg")
                    case "Wizards": self.teamImage = UIImage(named: "was.jpg")
                    default: self.teamImage = UIImage(named: "placeholder.png")
                    }
                }
            } else {
                self.teamImage = UIImage.init(named: "placeholder.png")
                self.teamNameLabel.text = "N/A"
            }
            self.teamLogoImageView.image = self.teamImage
            
            if let yearFounded = team?.yearFounded {
                if yearFounded == "" {
                    self.teamYearFoundedLabel.text = "N/A"
                } else {
                    self.teamYearFoundedLabel.text = yearFounded
                }
            } else {
                self.teamYearFoundedLabel.text = "N/A"
            }
            
            if let city = team?.city {
                if city == "" {
                    self.teamCityLabel.text = "N/A"
                } else {
                    self.teamCityLabel.text = city
                }
            } else {
                self.teamCityLabel.text = "N/A"
            }
            
            if let conference = team?.conference {
                if conference == "" {
                    self.teamConferenceLabel.text = "N/A"
                } else {
                    self.teamConferenceLabel.text = conference
                }
            } else {
                self.teamConferenceLabel.text = "N/A"
            }
            
            if let division = team?.division {
                if division == "" {
                    self.teamDivisionLabel.text = "N/A"
                } else {
                    self.teamDivisionLabel.text = team?.division
                }
            } else {
                self.teamDivisionLabel.text = "N/A"
            }
            
            if let wins = team?.wins, let losses = team?.losses {
                if wins == "" || losses == "" {
                    self.teamRecordLabel.text = "N/A"
                } else {
                    self.teamRecordLabel.text = "\(wins) - \(losses)"
                }
            } else {
                self.teamConferenceRankLabel.text = "N/A"
            }
            
            if let conferenceRank = team?.conferenceRank {
                if conferenceRank == "" {
                    self.teamConferenceRankLabel.text = "N/A"
                } else {
                    self.teamConferenceRankLabel.text = team?.conferenceRank
                }
            } else {
                self.teamConferenceRankLabel.text = "N/A"
            }
            
            if let divisonRank = team?.divisionRank {
                if divisonRank == "" {
                    self.teamDivisionRankLabel.text = "N/A"
                } else {
                    self.teamDivisionRankLabel.text = team?.divisionRank
                }
            } else {
                self.teamDivisionRankLabel.text = "N/A"
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? PlayersTableVC
        detailVC?.selectedTeamID = teamToPass?.ID
    }
}
