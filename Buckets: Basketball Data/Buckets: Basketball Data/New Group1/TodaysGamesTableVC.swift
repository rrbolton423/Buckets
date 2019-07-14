//
//  TodaysGamesTableVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit

class TodaysGamesTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGamesImage: UIImageView!
    @IBOutlet weak var noGames: UILabel!
    
    let section = ["Yesterday's Games", "Today's Games", "Tomorrow's Games"]
    let gamesAPI = GameAPI()
    var todaysGames = [Game]()
    var yesterdaysGames = [Game]()
    var tomorrowsGames = [Game]()
    var allGames = [[Game]]()
    var gameToPass: Game?
    var awayTeamImage: UIImage?
    var homeTeamImage: UIImage?
    var activityIndicator = UIActivityIndicatorView(style: .gray)
    var use_real_images: String?
    var appLaunches = UserDefaults.standard.integer(forKey: "appLaunches")
    var refreshController = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseConstants().setupAPP()
        self.use_real_images = FirebaseConstants().getImages()
        defaultsChanged()
        self.setNoGamesImage()
        setupInfoBarButtonItem()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupInfoBarButtonItem() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func infoButtonTapped() {
        let alert = UIAlertController(title: "Buckets: Basketball Data (v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? ""))", message: "Disclaimer: This app is not endorsed by or affiliated with the National Basketball Association. Any trademarks used in the app are done so under “fair use” with the sole purpose of identifying the respective entities, and remain the property of their respective owners.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tableView.visibleCells.isEmpty {
            start()
        } else {
            if (!self.refreshController.isRefreshing) {self.activityIndicator.startAnimating()}
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.refreshController.endRefreshing()
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
        self.noGames.textColor = .white
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
        self.navigationController?.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.barStyle = .default
        self.noGames.textColor = .black
        self.tableView.indicatorStyle = .default;
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    @objc func start() {
        tableView.addSubview(refreshController)
        refreshController.addTarget(self, action: #selector(startWithRefreshController), for: .valueChanged)
        firebaseSetup()
        if CheckInternet.connection() {
            loadGamesWithActivityIndicator()
        } else {
            self.tableView.isUserInteractionEnabled = true
            self.yesterdaysGames.removeAll()
            self.todaysGames.removeAll()
            self.tomorrowsGames.removeAll()
            self.allGames.removeAll()
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.navigationController?.popToRootViewController(animated: true)
            displayConnectionErrorAlert()
        }
    }
    
    @objc func refresh() {
        start()
    }
    
    @objc func startWithRefreshController() {
        tableView.addSubview(refreshController)
        refreshController.addTarget(self,  action: #selector(startWithRefreshController), for: .valueChanged)
        firebaseSetup()
        if CheckInternet.connection() {
            loadGamesWithRefreshController()
        } else {
            self.tableView.isUserInteractionEnabled = true
            self.allGames.removeAll()
            self.yesterdaysGames.removeAll()
            self.todaysGames.removeAll()
            self.tomorrowsGames.removeAll()
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.navigationController?.popToRootViewController(animated: true)
            displayConnectionErrorAlert()
        }
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
    
    func setNoGamesImage() {
        if self.use_real_images == "false" {
            self.noGamesImage.image = UIImage(named: "tvstatic.png")
        } else {
            self.noGamesImage.image = UIImage(named: "nba_logo.png")
        }
    }
    
    func loadGamesWithRefreshController(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        self.tableView.isUserInteractionEnabled = false
        self.allGames.removeAll()
        self.yesterdaysGames.removeAll()
        self.todaysGames.removeAll()
        self.tomorrowsGames.removeAll()
        self.tableView.reloadData()
        DispatchQueue.global(qos: .background).async {
            let yesterdaysDate = self.gamesAPI.getYesterdaysDate()
            let todaysDate = self.gamesAPI.getTodaysDate()
            let tomorrowsDate = self.gamesAPI.getTomorrowsDate()
            self.gamesAPI.getGames(yesterdaysDate: yesterdaysDate, todaysDate: todaysDate, url: ScoreBoardURL, tomorrowsDate: tomorrowsDate, completion: { returnedGames, error in
                if error == nil {
                    if let games = returnedGames {
                        if games[0].count > 0 || games[1].count > 0 || games[2].count > 0 {
                            self.allGames = games
                            self.yesterdaysGames = games[0]
                            self.todaysGames = games[1]
                            self.tomorrowsGames = games[2]
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.noGames.isHidden = true
                                self.noGamesImage.isHidden = true
                                self.refreshController.endRefreshing()
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.removeFromSuperview()
                                self.tableView.isUserInteractionEnabled = true
                            }
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        DispatchQueue.main.async{
                            self.tableView.isHidden = true
                            self.noGames.isHidden = false
                            self.setNoGamesImage()
                            self.noGamesImage.isHidden = false
                            self.refreshController.endRefreshing()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.removeFromSuperview()
                            self.tableView.isUserInteractionEnabled = false
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func loadGamesWithActivityIndicator(){
        self.tableView.isUserInteractionEnabled = false
        self.allGames.removeAll()
        self.yesterdaysGames.removeAll()
        self.todaysGames.removeAll()
        self.tomorrowsGames.removeAll()
        self.tableView.reloadData()
        setupActivityIndicator()
        if (!self.refreshController.isRefreshing) {self.activityIndicator.startAnimating()}
        DispatchQueue.global(qos: .background).async {
            let yesterdaysDate = self.gamesAPI.getYesterdaysDate()
            let todaysDate = self.gamesAPI.getTodaysDate()
            let tomorrowsDate = self.gamesAPI.getTomorrowsDate()
            self.gamesAPI.getGames(yesterdaysDate: yesterdaysDate, todaysDate: todaysDate, url: ScoreBoardURL, tomorrowsDate: tomorrowsDate, completion: { returnedGames, error in
                if error == nil {
                    if let games = returnedGames {
                        if games[0].count > 0 || games[1].count > 0 || games[2].count > 0 {
                            self.allGames = games
                            self.yesterdaysGames = games[0]
                            self.todaysGames = games[1]
                            self.tomorrowsGames = games[2]
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.noGames.isHidden = true
                                self.noGamesImage.isHidden = true
                                self.refreshController.endRefreshing()
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.removeFromSuperview()
                                self.tableView.isUserInteractionEnabled = true
                            }
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        DispatchQueue.main.async{
                            self.tableView.isHidden = true
                            self.noGames.isHidden = false
                            self.setNoGamesImage()
                            self.noGamesImage.isHidden = false
                            self.refreshController.endRefreshing()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.removeFromSuperview()
                            self.tableView.isUserInteractionEnabled = false
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 211
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            view.tintColor = hexStringToUIColor(hex: "#252525")
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .white
        } else {
            
            view.tintColor = UIColor.groupTableViewBackground
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .black
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
            if (allGames.count == 0) {
                return ""
            } else {
                return self.section[section]
            }
        } else {
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (allGames.count == 0) {
            return 0
        } else {
            return self.section.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.activityIndicator.removeFromSuperview()
        if (allGames.count == 0) {
            return 0
        } else {return self.allGames[section].count}
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var gameToTweet: Game?
        let section = indexPath.section
        if section == 0 {
            let row = indexPath.row
            gameToTweet = yesterdaysGames[row]
        } else if section == 1 {
            let row = indexPath.row
            gameToTweet = todaysGames[row]
        } else {
            let row = indexPath.row
            gameToTweet = tomorrowsGames[row]
        }
        let tweet = UITableViewRowAction(style: .default, title: "Tweet") { (action, indexPath) in
            if let awayTeam = gameToTweet?.awayTeamName, let homeTeam = gameToTweet?.homeTeamName, let awayScore = gameToTweet?.awayTeamScore, let homeScore = gameToTweet?.homeTeamScore, let gameQuarter = gameToTweet?.quarter, let gameVenue = gameToTweet?.arena {
                
                var tweetText: String = String()
                
                if gameQuarter.contains(":") {
                    tweetText = "\(awayTeam) vs. \(homeTeam) tips off at \(gameQuarter) from \(gameVenue)! Download the Buckets: Basketball Data app for more scores, stats and standings."
                } else if gameQuarter == "Final" {
                    tweetText = "FINAL SCORE: \(awayTeam) \(awayScore), \(homeTeam) \(homeScore). Download the Buckets: Basketball Data app for more scores, stats and standings."
                } else {
                    tweetText = "SCORE UPDATE: \(awayTeam) \(awayScore), \(homeTeam) \(homeScore) - \(gameQuarter)! Download the Buckets: Basketball Data app for more scores, stats and standings."
                }
                let tweetUrl = "https://itunes.apple.com/us/app/buckets-basketball-data/id1456202460?ls=1&mt=8"
                let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"
                let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                let url = URL(string: escapedShareString)
                if let url = URL(string: "\(url!)"), !url.absoluteString.isEmpty {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                return
            }
        }
        tweet.backgroundColor = hexStringToUIColor(hex: "#1DA1F2")
        return [tweet]
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        FirebaseConstants().setupAPP()
        self.use_real_images = FirebaseConstants().getImages()
        let cell = tableView.dequeueReusableCell(withIdentifier: "todaysGamesCell", for: indexPath) as! TodaysGamesCell
        if indexPath.section == 0 {
            if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
                cell.backgroundColor = .black
            } else {
                cell.backgroundColor = hexStringToUIColor(hex: "#d9d9d9")
            }
        } else {
            if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
                cell.backgroundColor = .black
            } else {
                cell.backgroundColor = .white
            }
        }
        cell.homeTeamNameLabel.text = allGames[indexPath.section][indexPath.row].homeTeamName
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.homeTeamNameLabel.textColor = .white
        } else {
            cell.homeTeamNameLabel.textColor = .black
        }
        cell.awayTeamNameLabel.text = allGames[indexPath.section][indexPath.row].awayTeamName
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.awayTeamNameLabel.textColor = .white
        } else {
            cell.awayTeamNameLabel.textColor = .black
        }
        if self.use_real_images == "false" {
            switch allGames[indexPath.section][indexPath.row].awayTeamName {
            case "BKN": self.awayTeamImage = UIImage(named: "BKN_placeholder.png")
            case "ATL": self.awayTeamImage = UIImage(named: "ATL_placeholder.png")
            case "BOS": self.awayTeamImage = UIImage(named: "BOS_placeholder.png")
            case "CHA": self.awayTeamImage = UIImage(named: "CHA_placeholder.png")
            case "CHI": self.awayTeamImage = UIImage(named: "CHI_placeholder.png")
            case "CLE": self.awayTeamImage = UIImage(named: "CLE_placeholder.png")
            case "DAL": self.awayTeamImage = UIImage(named: "DAL_placeholder.png")
            case "DEN": self.awayTeamImage = UIImage(named: "DEN_placeholder.png")
            case "DET": self.awayTeamImage = UIImage(named: "DET_placeholder.png")
            case "GSW": self.awayTeamImage = UIImage(named: "GSW_placeholder.png")
            case "HOU": self.awayTeamImage = UIImage(named: "HOU_placeholder.png")
            case "IND": self.awayTeamImage = UIImage(named: "IND_placeholder.png")
            case "LAC": self.awayTeamImage = UIImage(named: "LAC_placeholder.png")
            case "LAL": self.awayTeamImage = UIImage(named: "LAL_placeholder.png")
            case "MEM": self.awayTeamImage = UIImage(named: "MEM_placeholder.png")
            case "MIA": self.awayTeamImage = UIImage(named: "MIA_placeholder.png")
            case "MIL": self.awayTeamImage = UIImage(named: "MIL_placeholder.png")
            case "MIN": self.awayTeamImage = UIImage(named: "MIN_placeholder.png")
            case "NOP": self.awayTeamImage = UIImage(named: "NOP_placeholder.png")
            case "NYK": self.awayTeamImage = UIImage(named: "NYK_placeholder.png")
            case "OKC": self.awayTeamImage = UIImage(named: "OKC_placeholder.png")
            case "ORL": self.awayTeamImage = UIImage(named: "ORL_placeholder.png")
            case "PHI": self.awayTeamImage = UIImage(named: "PHI_placeholder.png")
            case "PHX": self.awayTeamImage = UIImage(named: "PHX_placeholder.png")
            case "POR": self.awayTeamImage = UIImage(named: "POR_placeholder.png")
            case "SAC": self.awayTeamImage = UIImage(named: "SAC_placeholder.png")
            case "SAS": self.awayTeamImage = UIImage(named: "SAS_placeholder.png")
            case "TOR": self.awayTeamImage = UIImage(named: "TOR_placeholder.png")
            case "UTA": self.awayTeamImage = UIImage(named: "UTA_placeholder.png")
            case "WAS": self.awayTeamImage = UIImage(named: "WAS_placeholder.png")
            default: self.awayTeamImage = UIImage(named: "placeholder.png")
            }
        } else {
            switch allGames[indexPath.section][indexPath.row].awayTeamName {
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
            default: self.awayTeamImage = UIImage(named: "nba_logo.png")
            }
        }
        if self.use_real_images == "false" {
            switch allGames[indexPath.section][indexPath.row].homeTeamName {
            case "BKN": self.homeTeamImage = UIImage(named: "BKN_placeholder.png")
            case "ATL": self.homeTeamImage = UIImage(named: "ATL_placeholder.png")
            case "BOS": self.homeTeamImage = UIImage(named: "BOS_placeholder.png")
            case "CHA": self.homeTeamImage = UIImage(named: "CHA_placeholder.png")
            case "CHI": self.homeTeamImage = UIImage(named: "CHI_placeholder.png")
            case "CLE": self.homeTeamImage = UIImage(named: "CLE_placeholder.png")
            case "DAL": self.homeTeamImage = UIImage(named: "DAL_placeholder.png")
            case "DEN": self.homeTeamImage = UIImage(named: "DEN_placeholder.png")
            case "DET": self.homeTeamImage = UIImage(named: "DET_placeholder.png")
            case "GSW": self.homeTeamImage = UIImage(named: "GSW_placeholder.png")
            case "HOU": self.homeTeamImage = UIImage(named: "HOU_placeholder.png")
            case "IND": self.homeTeamImage = UIImage(named: "IND_placeholder.png")
            case "LAC": self.homeTeamImage = UIImage(named: "LAC_placeholder.png")
            case "LAL": self.homeTeamImage = UIImage(named: "LAL_placeholder.png")
            case "MEM": self.homeTeamImage = UIImage(named: "MEM_placeholder.png")
            case "MIA": self.homeTeamImage = UIImage(named: "MIA_placeholder.png")
            case "MIL": self.homeTeamImage = UIImage(named: "MIL_placeholder.png")
            case "MIN": self.homeTeamImage = UIImage(named: "MIN_placeholder.png")
            case "NOP": self.homeTeamImage = UIImage(named: "NOP_placeholder.png")
            case "NYK": self.homeTeamImage = UIImage(named: "NYK_placeholder.png")
            case "OKC": self.homeTeamImage = UIImage(named: "OKC_placeholder.png")
            case "ORL": self.homeTeamImage = UIImage(named: "ORL_placeholder.png")
            case "PHI": self.homeTeamImage = UIImage(named: "PHI_placeholder.png")
            case "PHX": self.homeTeamImage = UIImage(named: "PHX_placeholder.png")
            case "POR": self.homeTeamImage = UIImage(named: "POR_placeholder.png")
            case "SAC": self.homeTeamImage = UIImage(named: "SAC_placeholder.png")
            case "SAS": self.homeTeamImage = UIImage(named: "SAS_placeholder.png")
            case "TOR": self.homeTeamImage = UIImage(named: "TOR_placeholder.png")
            case "UTA": self.homeTeamImage = UIImage(named: "UTA_placeholder.png")
            case "WAS": self.homeTeamImage = UIImage(named: "WAS_placeholder.png")
            default: self.homeTeamImage = UIImage(named: "placeholder.png")
            }
        } else {
            switch allGames[indexPath.section][indexPath.row].homeTeamName {
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
            default: self.homeTeamImage = UIImage(named: "nba_logo.png")
            }
        }
        cell.homeTeamImageView.image = homeTeamImage
        cell.awayTeamImageView.image = awayTeamImage
        cell.tipoffLabel.text = allGames[indexPath.section][indexPath.row].quarter
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.tipoffLabel.textColor = .white
        } else {
            cell.tipoffLabel.textColor = .black
        }
        let awayScore = allGames[indexPath.section][indexPath.row].awayTeamScore
        if awayScore == "" {
            cell.awayScoreLabel.text = "0"
        } else {
            cell.awayScoreLabel.text = awayScore
        }
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.awayScoreLabel.textColor = .white
        } else {
            cell.awayScoreLabel.textColor = .black
        }
        let homeScore = allGames[indexPath.section][indexPath.row].homeTeamScore
        if homeScore == "" {
            cell.homeScoreLabel.text = "0"
        } else {
            cell.homeScoreLabel.text = homeScore
        }
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.homeScoreLabel.textColor = .white
        } else {
            cell.homeScoreLabel.textColor = .black
        }
        cell.venueLabel.text = allGames[indexPath.section][indexPath.row].arena
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.venueLabel.textColor = .white
        } else {
            cell.venueLabel.textColor = .black
        }
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.versusLabel.textColor = .white
        } else {
            cell.versusLabel.textColor = .black
        }
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell.dividerLabel.textColor = .white
        } else {
            cell.dividerLabel.textColor = .black
        }
        return cell
    }
    
    func displayConnectionErrorAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            self.refreshController.endRefreshing()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadGame" {
            if let detailVC = segue.destination as? VideoViewController {
                let section = tableView.indexPathForSelectedRow!.section
                if section == 0 {
                    let row = tableView.indexPathForSelectedRow!.row
                    gameToPass = yesterdaysGames[row]
                } else if section == 1 {
                    let row = tableView.indexPathForSelectedRow!.row
                    gameToPass = todaysGames[row]
                } else {
                    let row = tableView.indexPathForSelectedRow!.row
                    gameToPass = tomorrowsGames[row]
                }
                detailVC.game = gameToPass
            }
        }
    }
}
