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
    var use_real_images: String?
    
    fileprivate func start() {
        setupInfoBarButtonItem()
        firebaseSetup()
        checkForTeamID()
        fetchRoster()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    func setupInfoBarButtonItem() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    @objc func getInfoAction() {
        let alert = UIAlertController(title: "Buckets v.1.0", message: "This app is not endorsed by or affiliated with the National Basketball Association. Any trademarks used in the app are done so under “fair use” with the sole purpose of identifying the respective entities, and remain the property of their respective owners.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func firebaseSetup() {
        DispatchQueue.global(qos: .background).async {
            FirebaseConstants().setupAPP()
            self.use_real_images = FirebaseConstants().getImages()
        }
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(self.activityIndicator)
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
            DispatchQueue.main.async {
                self.setupActivityIndicator()
                self.activityIndicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async {
                let teamApi = TeamAPI()
                if let teamInfoURL = self.teamInfoURL {
                    teamApi.getTeamInfo(url: teamInfoURL) { (detailTeam) in
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.removeFromSuperview()
                            self.teamToPass = detailTeam
                            self.showInfoDetail(team: detailTeam)
                        }
                    }
                }
            }     
        } else {
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
            }
        }
    }
    
    func showInfoDetail(team: DetailTeam?) {
        if let city = team?.city, let name = team?.name {
            if name == "" {
                self.teamNameLabel.text = "N/A"
            } else {
                self.teamNameLabel.text = "\(city) \(name)"
                self.navigationItem.title = "\(city) \(name)"
                if self.use_real_images == "false" {
                    self.teamImage = UIImage(named: "placeholder.png")
                } else {
                    switch name {
                    case "Nets": self.teamImage = UIImage(named: "bkn.png")
                    case "Hawks": self.teamImage = UIImage(named: "atl.png")
                    case "Celtics": self.teamImage = UIImage(named: "bos.png")
                    case "Hornets": self.teamImage = UIImage(named: "cha.png")
                    case "Bulls": self.teamImage = UIImage(named: "chi.png")
                    case "Cavaliers": self.teamImage = UIImage(named: "cle.png")
                    case "Mavericks": self.teamImage = UIImage(named: "dal.png")
                    case "Nuggets": self.teamImage = UIImage(named: "den.png")
                    case "Pistons": self.teamImage = UIImage(named: "det.png")
                    case "Warriors": self.teamImage = UIImage(named: "gsw.png")
                    case "Rockets": self.teamImage = UIImage(named: "hou.png")
                    case "Pacers": self.teamImage = UIImage(named: "ind.png")
                    case "Clippers": self.teamImage = UIImage(named: "lac.png")
                    case "Lakers": self.teamImage = UIImage(named: "lal.png")
                    case "Grizzlies": self.teamImage = UIImage(named: "mem.png")
                    case "Heat": self.teamImage = UIImage(named: "mia.png")
                    case "Bucks": self.teamImage = UIImage(named: "mil.png")
                    case "Timberwolves": self.teamImage = UIImage(named: "min.png")
                    case "Pelicans": self.teamImage = UIImage(named: "nop.png")
                    case "Knicks": self.teamImage = UIImage(named: "nyk.png")
                    case "Thunder": self.teamImage = UIImage(named: "okc.png")
                    case "Magic": self.teamImage = UIImage(named: "orl.png")
                    case "76ers": self.teamImage = UIImage(named: "phi.png")
                    case "Suns": self.teamImage = UIImage(named: "phx.png")
                    case "Trail Blazers": self.teamImage = UIImage(named: "por.png")
                    case "Kings": self.teamImage = UIImage(named: "sac.png")
                    case "Spurs": self.teamImage = UIImage(named: "sas.png")
                    case "Raptors": self.teamImage = UIImage(named: "tor.png")
                    case "Jazz": self.teamImage = UIImage(named: "uta.png")
                    case "Wizards": self.teamImage = UIImage(named: "was.png")
                    default: self.teamImage = UIImage(named: "placeholder.png")
                    }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? PlayersTableVC
        detailVC?.selectedTeamID = teamToPass?.ID
    }
}
