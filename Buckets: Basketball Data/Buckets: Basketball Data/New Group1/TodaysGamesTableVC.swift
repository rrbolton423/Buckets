//
//  TodaysGamesTableVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import UserNotifications

class TodaysGamesTableVC: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGamesimage: UIImageView!
    @IBOutlet weak var noGames: UILabel!
    let NBAapi = NBA_API()
    var games = [Game]()
    var awayTeamImage: UIImage?
    var homeTeamImage: UIImage?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var use_real_images: String?
    
    fileprivate func start() {
        firebaseSetup()
        setupInfoBarButtonItem()
        addNavBarRefreshButton()
        if CheckInternet.connection() {
            loadTodaysGames()
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func firebaseSetup() {
        DispatchQueue.global(qos: .background).async {
            FirebaseConstants().setupAPP()
            self.use_real_images = FirebaseConstants().getImages()
            print(self.use_real_images)
        }
    }
    
    func addNavBarRefreshButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.refresh, target: self, action:
            #selector(refresh))
    }
    
    func loadTodaysGames(){
        self.games.removeAll()
        self.tableView.reloadData()
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async {
            let nbaDate = self.NBAapi.getTodaysDate()
            self.NBAapi.getScores(date: nbaDate) { returnedGames in
                if returnedGames.count > 0 {
                    self.games = returnedGames
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.noGames.isHidden = true
                        self.noGamesimage.isHidden = true
                        self.activityIndicator.removeFromSuperview()
                        self.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async{
                        self.tableView.isHidden = true
                        self.noGames.isHidden = false
                        if self.use_real_images == "false" {
                            self.noGamesimage.image = UIImage(named: "placeholder.png")
                        } else {
                            self.noGamesimage.image = UIImage(named: "jordan.png")
                        }
                        self.noGamesimage.isHidden = false
                        self.activityIndicator.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    @objc func refresh() {
        navigationItem.leftBarButtonItem?.isEnabled = false
        start()
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 211
    }
    
    func setupInfoBarButtonItem() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    @objc func getInfoAction() {
        let alert = UIAlertController(title: "Version 1.0", message: "This app is not endorsed by or affiliated with the National Basketball Association. Any trademarks used in the app are done so under “fair use” with the sole purpose of identifying the respective entities, and remain the property of their respective owners.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return gameData.count
        self.activityIndicator.removeFromSuperview()
        return games.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todaysGamesCell", for: indexPath) as! TodaysGamesCell
        cell.homeTeamName.text = games[indexPath.row].homeTeamName
        cell.awayTeamName.text = games[indexPath.row].awayTeamName
        
        if self.use_real_images == "false" {
            self.awayTeamImage = UIImage(named: "placeholder.png")
        } else {
            switch games[indexPath.row].awayTeamName {
            case "BKN": self.awayTeamImage = UIImage(named: "bkn.png")
            case "ATL": self.awayTeamImage = UIImage(named: "atl.png")
            case "BOS": self.awayTeamImage = UIImage(named: "bos.png")
            case "CHA": self.awayTeamImage = UIImage(named: "cha.png")
            case "CHI": self.awayTeamImage = UIImage(named: "chi.png")
            case "CLE": self.awayTeamImage = UIImage(named: "cle.png")
            case "DAL": self.awayTeamImage = UIImage(named: "dal.png")
            case "DEN": self.awayTeamImage = UIImage(named: "den.png")
            case "DET": self.awayTeamImage = UIImage(named: "det.png")
            case "GSW": self.awayTeamImage = UIImage(named: "gsw.png")
            case "HOU": self.awayTeamImage = UIImage(named: "hou.png")
            case "IND": self.awayTeamImage = UIImage(named: "ind.png")
            case "LAC": self.awayTeamImage = UIImage(named: "lac.png")
            case "LAL": self.awayTeamImage = UIImage(named: "lal.png")
            case "MEM": self.awayTeamImage = UIImage(named: "mem.png")
            case "MIA": self.awayTeamImage = UIImage(named: "mia.png")
            case "MIL": self.awayTeamImage = UIImage(named: "mil.png")
            case "MIN": self.awayTeamImage = UIImage(named: "min.png")
            case "NOP": self.awayTeamImage = UIImage(named: "nop.png")
            case "NYK": self.awayTeamImage = UIImage(named: "nyk.png")
            case "OKC": self.awayTeamImage = UIImage(named: "okc.png")
            case "ORL": self.awayTeamImage = UIImage(named: "orl.png")
            case "PHI": self.awayTeamImage = UIImage(named: "phi.png")
            case "PHX": self.awayTeamImage = UIImage(named: "phx.png")
            case "POR": self.awayTeamImage = UIImage(named: "por.png")
            case "SAC": self.awayTeamImage = UIImage(named: "sac.png")
            case "SAS": self.awayTeamImage = UIImage(named: "sas.png")
            case "TOR": self.awayTeamImage = UIImage(named: "tor.png")
            case "UTA": self.awayTeamImage = UIImage(named: "uta.png")
            case "WAS": self.awayTeamImage = UIImage(named: "was.png")
            default: self.awayTeamImage = UIImage(named: "placeholder.png")
            }
        }
        
        if self.use_real_images == "false" {
            self.homeTeamImage = UIImage(named: "placeholder.png")
        } else {
            switch games[indexPath.row].homeTeamName {
            case "BKN": self.homeTeamImage = UIImage(named: "bkn.png")
            case "ATL": self.homeTeamImage = UIImage(named: "atl.png")
            case "BOS": self.homeTeamImage = UIImage(named: "bos.png")
            case "CHA": self.homeTeamImage = UIImage(named: "cha.png")
            case "CHI": self.homeTeamImage = UIImage(named: "chi.png")
            case "CLE": self.homeTeamImage = UIImage(named: "cle.png")
            case "DAL": self.homeTeamImage = UIImage(named: "dal.png")
            case "DEN": self.homeTeamImage = UIImage(named: "den.png")
            case "DET": self.homeTeamImage = UIImage(named: "det.png")
            case "GSW": self.homeTeamImage = UIImage(named: "gsw.png")
            case "HOU": self.homeTeamImage = UIImage(named: "hou.png")
            case "IND": self.homeTeamImage = UIImage(named: "ind.png")
            case "LAC": self.homeTeamImage = UIImage(named: "lac.png")
            case "LAL": self.homeTeamImage = UIImage(named: "lal.png")
            case "MEM": self.homeTeamImage = UIImage(named: "mem.png")
            case "MIA": self.homeTeamImage = UIImage(named: "mia.png")
            case "MIL": self.homeTeamImage = UIImage(named: "mil.png")
            case "MIN": self.homeTeamImage = UIImage(named: "min.png")
            case "NOP": self.homeTeamImage = UIImage(named: "nop.png")
            case "NYK": self.homeTeamImage = UIImage(named: "nyk.png")
            case "OKC": self.homeTeamImage = UIImage(named: "okc.png")
            case "ORL": self.homeTeamImage = UIImage(named: "orl.png")
            case "PHI": self.homeTeamImage = UIImage(named: "phi.png")
            case "PHX": self.homeTeamImage = UIImage(named: "phx.png")
            case "POR": self.homeTeamImage = UIImage(named: "por.png")
            case "SAC": self.homeTeamImage = UIImage(named: "sac.png")
            case "SAS": self.homeTeamImage = UIImage(named: "sas.png")
            case "TOR": self.homeTeamImage = UIImage(named: "tor.png")
            case "UTA": self.homeTeamImage = UIImage(named: "uta.png")
            case "WAS": self.homeTeamImage = UIImage(named: "was.png")
            default: self.homeTeamImage = UIImage(named: "placeholder.png")
            }
        }
        cell.homeAfbeelding.image = homeTeamImage
        cell.awayAfbeelding.image = awayTeamImage
        cell.puckDrop.text = games[indexPath.row].quarter
        
        let awayScore = games[indexPath.row].awayTeamScore
        if awayScore == "" {
            cell.awayScore.text = "0"
        } else {
            cell.awayScore.text = awayScore
        }
        
        let homeScore = games[indexPath.row].homeTeamScore
        if homeScore == "" {
            cell.homeScore.text = "0"
        } else {
            cell.homeScore.text = awayScore
        }
        
        cell.venue.text = games[indexPath.row].arena
        return cell
    }
}

