//
//  StandingsTableVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import Foundation

class StandingsTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    
    var teams: [StandingTeam] = []
    var eastTeams: [StandingTeam] = []
    var westTeams: [StandingTeam] = []
    var gamesPlayed: [Int] = []
    var overTime: [Int] = []
    var wins: [Int] = []
    var loses: [Int] = []
    var points: [Int] = []
    var teamImage: UIImage?
    let date = Date()
    var standingsURL: String? = String()
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var use_real_images: String?
    
    fileprivate func start() {
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        firebaseSetup()
        setupInfoBarButtonItem()
        standingsURL = "https://stats.nba.com/stats/scoreboardV2?DayOffset=0&LeagueID=00&gameDate=\(date.month)%2F\(date.day)%2F\(date.year)"
        loadStandings()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    func firebaseSetup() {
        DispatchQueue.global(qos: .background).async {
            FirebaseConstants().setupAPP()
            self.use_real_images = FirebaseConstants().getImages()
        }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    fileprivate func setupActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(self.activityIndicator)
    }
    
    func loadStandings(){
        fetchStandings()
    }
    
    func fetchStandings() {
        firebaseSetup()
        if CheckInternet.connection() {
            DispatchQueue.main.async {
                self.eastTeams.removeAll()
                self.westTeams.removeAll()
                self.tableView.reloadData()
                self.setupActivityIndicator()
                self.activityIndicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async {
                let eastStandingsAPI = EastStandingsAPI()
                if let eastStandingsURL = self.standingsURL {
                    eastStandingsAPI.getStandings(url: eastStandingsURL) { (eastTeams) in
                        self.eastTeams = eastTeams
                    }
                }
                let westStandingsAPI = WestStandingsAPI()
                if let westStandingsURL = self.standingsURL {
                    westStandingsAPI.getStandings(url: westStandingsURL) { (westTeams) in
                        self.westTeams = westTeams
                    }
                }
                DispatchQueue.main.async {
                    self.activityIndicator.removeFromSuperview()
                    self.tableView.reloadData()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.removeFromSuperview()
                self.navigationController?.popToRootViewController(animated: true)
                self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var returnValue = 0
        switch(segmentedControl?.selectedSegmentIndex)
        {
        case 0:
            returnValue = eastTeams.count
            break
        case 1:
            returnValue = westTeams.count
            break
        default:
            break
        }
        return returnValue
    }
    
    @IBAction func segmentedControlActionChanged(sender: AnyObject) {
        segmentedControl?.isEnabled = false
        start()
        segmentedControl?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standingsCell", for: indexPath) as! StandingsCell
        
        switch(segmentedControl?.selectedSegmentIndex)
        {
        case 0:
            if self.use_real_images == "false" {
                self.teamImage = UIImage(named: "placeholder.png")
            } else {
                switch eastTeams[indexPath.row].team {
                case "Brooklyn": self.teamImage = UIImage(named: "bkn.png")//
                case "Atlanta": self.teamImage = UIImage(named: "atl.png")
                case "Boston": self.teamImage = UIImage(named: "bos.png")//
                case "Charlotte": self.teamImage = UIImage(named: "cha.png")//
                case "Chicago": self.teamImage = UIImage(named: "chi.png")//
                case "Cleveland": self.teamImage = UIImage(named: "cle.png")//
                case "Dallas": self.teamImage = UIImage(named: "dal.png")//
                case "Denver": self.teamImage = UIImage(named: "den.png")//
                case "Detroit": self.teamImage = UIImage(named: "det.png")//
                case "Golden State": self.teamImage = UIImage(named: "gsw.png")//
                case "Houston": self.teamImage = UIImage(named: "hou.png")//
                case "Indiana": self.teamImage = UIImage(named: "ind.png")//
                case "LA Clippers": self.teamImage = UIImage(named: "lac.png")//
                case "L.A. Lakers": self.teamImage = UIImage(named: "lal.png")//
                case "Memphis": self.teamImage = UIImage(named: "mem.png")//
                case "Miami": self.teamImage = UIImage(named: "mia.png")//
                case "Milwaukee": self.teamImage = UIImage(named: "mil.png")//
                case "Minnesota": self.teamImage = UIImage(named: "min.png")//
                case "New Orleans": self.teamImage = UIImage(named: "nop.png")//
                case "New York": self.teamImage = UIImage(named: "nyk.png")//
                case "Oklahoma City": self.teamImage = UIImage(named: "okc.png")//
                case "Orlando": self.teamImage = UIImage(named: "orl.png")//
                case "Philadelphia": self.teamImage = UIImage(named: "phi.png")//
                case "Phoenix": self.teamImage = UIImage(named: "phx.png")//
                case "Portland": self.teamImage = UIImage(named: "por.png")//
                case "Sacramento": self.teamImage = UIImage(named: "sac.png")//
                case "San Antonio": self.teamImage = UIImage(named: "sas.png")//
                case "Toronto": self.teamImage = UIImage(named: "tor.png")//
                case "Utah": self.teamImage = UIImage(named: "uta.png")//
                case "Washington": self.teamImage = UIImage(named: "was.png")//
                default: self.teamImage = UIImage(named: "placeholder.png")
                }
            }
            cell.standing.text = String(indexPath.row + 1)
            cell.teamImage.image = teamImage
            cell.gamesPlayed.text = eastTeams[indexPath.row].gamesPlayed
            cell.wins.text = eastTeams[indexPath.row].wins
            cell.losses.text = eastTeams[indexPath.row].losses
            let value: Float = (eastTeams[indexPath.row].winPercentage?.floatValue)!
            cell.winPercentage.text = value.string(fractionDigits: 3)
            break
        case 1:
            if self.use_real_images == "false" {
                self.teamImage = UIImage(named: "placeholder.png")
            } else {
                switch westTeams[indexPath.row].team {
                case "Brooklyn": self.teamImage = UIImage(named: "bkn.png")//
                case "Atlanta": self.teamImage = UIImage(named: "atl.png")
                case "Boston": self.teamImage = UIImage(named: "bos.png")//
                case "Charlotte": self.teamImage = UIImage(named: "cha.png")//
                case "Chicago": self.teamImage = UIImage(named: "chi.png")//
                case "Cleveland": self.teamImage = UIImage(named: "cle.png")//
                case "Dallas": self.teamImage = UIImage(named: "dal.png")//
                case "Denver": self.teamImage = UIImage(named: "den.png")//
                case "Detroit": self.teamImage = UIImage(named: "det.png")//
                case "Golden State": self.teamImage = UIImage(named: "gsw.png")//
                case "Houston": self.teamImage = UIImage(named: "hou.png")//
                case "Indiana": self.teamImage = UIImage(named: "ind.png")//
                case "LA Clippers": self.teamImage = UIImage(named: "lac.png")//
                case "L.A. Lakers": self.teamImage = UIImage(named: "lal.png")//
                case "Memphis": self.teamImage = UIImage(named: "mem.png")//
                case "Miami": self.teamImage = UIImage(named: "mia.png")//
                case "Milwaukee": self.teamImage = UIImage(named: "mil.png")//
                case "Minnesota": self.teamImage = UIImage(named: "min.png")//
                case "New Orleans": self.teamImage = UIImage(named: "nop.png")//
                case "New York": self.teamImage = UIImage(named: "nyk.png")//
                case "Oklahoma City": self.teamImage = UIImage(named: "okc.png")//
                case "Orlando": self.teamImage = UIImage(named: "orl.png")//
                case "Philadelphia": self.teamImage = UIImage(named: "phi.png")//
                case "Phoenix": self.teamImage = UIImage(named: "phx.png")//
                case "Portland": self.teamImage = UIImage(named: "por.png")//
                case "Sacramento": self.teamImage = UIImage(named: "sac.png")//
                case "San Antonio": self.teamImage = UIImage(named: "sas.png")//
                case "Toronto": self.teamImage = UIImage(named: "tor.png")//
                case "Utah": self.teamImage = UIImage(named: "uta.png")//
                case "Washington": self.teamImage = UIImage(named: "was.png")
                default: self.teamImage = UIImage(named: "placeholder.png")
                }
            }
            cell.standing.text = String(indexPath.row + 1)
            cell.teamImage.image = teamImage
            cell.gamesPlayed.text = westTeams[indexPath.row].gamesPlayed
            cell.wins.text = westTeams[indexPath.row].wins
            cell.losses.text = westTeams[indexPath.row].losses
            cell.winPercentage.text = westTeams[indexPath.row].winPercentage
            let value: Float = (westTeams[indexPath.row].winPercentage?.floatValue)!
            cell.winPercentage.text = value.string(fractionDigits: 3)
            break
        default:
            break
        }
        return cell
    }
}
