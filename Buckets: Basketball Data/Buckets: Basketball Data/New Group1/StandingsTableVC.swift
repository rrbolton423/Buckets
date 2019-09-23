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
    var segmentedController: UISegmentedControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSegmentedController()
        FirebaseConstants().setupAPP()
        self.use_real_images = FirebaseConstants().getImages()
        defaultsChanged()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    @objc func defaultsChanged(){
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            updateToDarkTheme()
            tableView.reloadData()
        } else {
            updateToLightTheme()
            tableView.reloadData()
        }
    }
    
    func updateToDarkTheme(){
        navigationController?.view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        self.tableView.indicatorStyle = .white;
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        self.tableView.indicatorStyle = .default;
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func setupSegmentedController() {
        let items = ["East", "West"]
        segmentedController = UISegmentedControl(items: items)
        segmentedController.setWidth(80, forSegmentAt: 0)
        segmentedController.setWidth(80, forSegmentAt: 1)
        if let value = UserDefaults.standard.value(forKey: "chosenConference"){
            let selectedIndex = value as! Int
            segmentedController.selectedSegmentIndex = selectedIndex
        } else {
            segmentedController.selectedSegmentIndex = 0
            UserDefaults.standard.set(0, forKey: "chosenConference")
        }
        segmentedController.addTarget(self, action: #selector(changeConference), for: .valueChanged)
        navigationItem.titleView = segmentedController
    }
    
    @objc func start() {
        if (eastTeams.count > 0) || (westTeams.count > 0) {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.tableView.isUserInteractionEnabled = true
            self.segmentedController?.isEnabled = true
            return
        }
        firebaseSetup()
        standingsURL = "\(StandingsURL)\(date.month)%2F\(date.day)%2F\(Int(date.year)! + 1)"
        fetchStandings()
        self.tableView.reloadData()
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
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.color = UIColor.gray
        self.view.addSubview(self.activityIndicator)
    }
    
    func fetchStandings() {
        firebaseSetup()
        if CheckInternet.connection() {
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = false
                self.eastTeams.removeAll()
                self.westTeams.removeAll()
                self.tableView.reloadData()
                self.setupActivityIndicator()
                self.activityIndicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async {
                let eastStandingsAPI = EastStandingsAPI()
                if let eastStandingsURL = self.standingsURL {
                    eastStandingsAPI.getStandings(url: eastStandingsURL) { eastTeams, error  in
                        if error == nil {
                            if let unrwappedEastTeams = eastTeams {
                                self.eastTeams = unrwappedEastTeams
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.eastTeams.removeAll()
                                self.westTeams.removeAll()
                                self.tableView.reloadData()
                                self.tableView.isUserInteractionEnabled = true
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.removeFromSuperview()
                                let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                                    self.navigationController?.popToRootViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                let westStandingsAPI = WestStandingsAPI()
                if let westStandingsURL = self.standingsURL {
                    westStandingsAPI.getStandings(url: westStandingsURL) { westTeams, error in
                        if error == nil {
                            if let unrwappedWestTeams = westTeams {
                                self.westTeams = unrwappedWestTeams
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.eastTeams.removeAll()
                                self.westTeams.removeAll()
                                self.tableView.reloadData()
                                self.tableView.isUserInteractionEnabled = true
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.removeFromSuperview()
                                let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                                    self.navigationController?.popToRootViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    self.tableView.isUserInteractionEnabled = true
                }
            }
        } else {
            DispatchQueue.main.async {
                self.eastTeams.removeAll()
                self.westTeams.removeAll()
                self.tableView.reloadData()
                self.tableView.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func changeConference(sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "chosenConference")
        FirebaseConstants().setupAPP()
        self.use_real_images = FirebaseConstants().getImages()
        start()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var returnValue = 0
        switch(segmentedController?.selectedSegmentIndex)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standingsCell", for: indexPath) as! StandingsCell
        cell.backgroundColor = .clear
        switch(segmentedController?.selectedSegmentIndex)
        {
        case 0:
            if self.use_real_images == "false" {
                switch eastTeams[indexPath.row].team {
                case "Brooklyn": self.teamImage = UIImage(named: "BKN_placeholder.png")
                case "Atlanta": self.teamImage = UIImage(named: "ATL_placeholder.png")
                case "Boston": self.teamImage = UIImage(named: "BOS_placeholder.png")
                case "Charlotte": self.teamImage = UIImage(named: "CHA_placeholder.png")
                case "Chicago": self.teamImage = UIImage(named: "CHI_placeholder.png")
                case "Cleveland": self.teamImage = UIImage(named: "CLE_placeholder.png")
                case "Detroit": self.teamImage = UIImage(named: "DET_placeholder.png")
                case "Indiana": self.teamImage = UIImage(named: "IND_placeholder.png")
                case "Miami": self.teamImage = UIImage(named: "MIA_placeholder.png")
                case "Milwaukee": self.teamImage = UIImage(named: "MIL_placeholder.png")
                case "New York": self.teamImage = UIImage(named: "NYK_placeholder.png")
                case "Orlando": self.teamImage = UIImage(named: "ORL_placeholder.png")
                case "Philadelphia": self.teamImage = UIImage(named: "PHI_placeholder.png")
                case "Toronto": self.teamImage = UIImage(named: "TOR_placeholder.png")
                case "Washington": self.teamImage = UIImage(named: "WAS_placeholder.png")
                default: self.teamImage = UIImage(named: "placeholder.png")
                }
            } else {
                switch eastTeams[indexPath.row].team {
                case "Brooklyn": self.teamImage = UIImage(named: "bkn.png")
                case "Atlanta": self.teamImage = UIImage(named: "atl.png")
                case "Boston": self.teamImage = UIImage(named: "bos.png")
                case "Charlotte": self.teamImage = UIImage(named: "cha.png")
                case "Chicago": self.teamImage = UIImage(named: "chi.png")
                case "Cleveland": self.teamImage = UIImage(named: "cle.png")
                case "Detroit": self.teamImage = UIImage(named: "det.png")
                case "Miami": self.teamImage = UIImage(named: "mia.png")
                case "Milwaukee": self.teamImage = UIImage(named: "mil.png")
                case "Minnesota": self.teamImage = UIImage(named: "min.png")
                case "New York": self.teamImage = UIImage(named: "nyk.png")
                case "Orlando": self.teamImage = UIImage(named: "orl.png")
                case "Philadelphia": self.teamImage = UIImage(named: "phi.png")
                case "Toronto": self.teamImage = UIImage(named: "tor.png")
                case "Washington": self.teamImage = UIImage(named: "was.png")
                default: self.teamImage = UIImage(named: "placeholder.png")
                }
            }
            cell.standingLabel.text = String(indexPath.row + 1)
            cell.teamImageView.image = teamImage
            cell.winsLabel.text = eastTeams[indexPath.row].wins
            cell.lossesLabel.text = eastTeams[indexPath.row].losses
            let value: Float = (eastTeams[indexPath.row].winPercentage?.floatValue)!
            cell.winPercentageLabel.text = value.string(fractionDigits: 3)
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            if isDarkMode == true {
                cell.standingLabel.textColor = .white
                cell.winsLabel.textColor = .white
                cell.lossesLabel.textColor = .white
                cell.winPercentageLabel.textColor = .white
                cell.lLabel.textColor = .white
                cell.wLabel.textColor = .white
                cell.wpLabel.textColor = .white
            } else {
                cell.standingLabel.textColor = .black
                cell.winsLabel.textColor = .black
                cell.lossesLabel.textColor = .black
                cell.winPercentageLabel.textColor = .black
                cell.lLabel.textColor = .black
                cell.wLabel.textColor = .black
                cell.wpLabel.textColor = .black
            }
            break
            
        case 1:
            if self.use_real_images == "false" {
                switch westTeams[indexPath.row].team {
                case "Dallas": self.teamImage = UIImage(named: "DAL_placeholder.png")
                case "Denver": self.teamImage = UIImage(named: "DEN_placeholder.png")
                case "Golden State": self.teamImage = UIImage(named: "GSW_placeholder.png")
                case "Houston": self.teamImage = UIImage(named: "HOU_placeholder.png")
                case "LA Clippers": self.teamImage = UIImage(named: "LAC_placeholder.png")
                case "L.A. Lakers": self.teamImage = UIImage(named: "LAL_placeholder.png")
                case "Memphis": self.teamImage = UIImage(named: "MEM_placeholder.png")
                case "Minnesota": self.teamImage = UIImage(named: "MIN_placeholder.png")
                case "New Orleans": self.teamImage = UIImage(named: "NOP_placeholder.png")
                case "Oklahoma City": self.teamImage = UIImage(named: "OKC_placeholder.png")
                case "Phoenix": self.teamImage = UIImage(named: "PHX_placeholder.png")
                case "Portland": self.teamImage = UIImage(named: "POR_placeholder.png")
                case "Sacramento": self.teamImage = UIImage(named: "SAC_placeholder.png")
                case "San Antonio": self.teamImage = UIImage(named: "SAS_placeholder.png")
                case "Utah": self.teamImage = UIImage(named: "UTA_placeholder.png")
                default: self.teamImage = UIImage(named: "placeholder.png")
                }
            } else {
                switch westTeams[indexPath.row].team {
                case "Dallas": self.teamImage = UIImage(named: "dal.png")
                case "Denver": self.teamImage = UIImage(named: "den.png")
                case "Golden State": self.teamImage = UIImage(named: "gsw.png")
                case "Houston": self.teamImage = UIImage(named: "hou.png")
                case "LA Clippers": self.teamImage = UIImage(named: "lac.png")
                case "L.A. Lakers": self.teamImage = UIImage(named: "lal.png")
                case "Memphis": self.teamImage = UIImage(named: "mem.png")
                case "Minnesota": self.teamImage = UIImage(named: "min.png")
                case "New Orleans": self.teamImage = UIImage(named: "nop.png")
                case "Oklahoma City": self.teamImage = UIImage(named: "okc.png")
                case "Phoenix": self.teamImage = UIImage(named: "phx.png")
                case "Portland": self.teamImage = UIImage(named: "por.png")
                case "Sacramento": self.teamImage = UIImage(named: "sac.png")
                case "San Antonio": self.teamImage = UIImage(named: "sas.png")
                case "Utah": self.teamImage = UIImage(named: "uta.png")
                default: self.teamImage = UIImage(named: "placeholder.png")
                }
            }
            cell.standingLabel.text = String(indexPath.row + 1)
            cell.teamImageView.image = teamImage
            cell.winsLabel.text = westTeams[indexPath.row].wins
            cell.lossesLabel.text = westTeams[indexPath.row].losses
            cell.winPercentageLabel.text = westTeams[indexPath.row].winPercentage
            let value: Float = (westTeams[indexPath.row].winPercentage?.floatValue)!
            cell.winPercentageLabel.text = value.string(fractionDigits: 3)
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            if isDarkMode == true {
                cell.standingLabel.textColor = .white
                cell.winsLabel.textColor = .white
                cell.lossesLabel.textColor = .white
                cell.winPercentageLabel.textColor = .white
                cell.lLabel.textColor = .white
                cell.wLabel.textColor = .white
                cell.wpLabel.textColor = .white
            } else {
                cell.standingLabel.textColor = .black
                cell.winsLabel.textColor = .black
                cell.lossesLabel.textColor = .black
                cell.winPercentageLabel.textColor = .black
                cell.lLabel.textColor = .black
                cell.wLabel.textColor = .black
                cell.wpLabel.textColor = .black
            }
            break
            
        default:
            break
        }
        return cell
    }
}
