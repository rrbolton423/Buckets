//
//  PlayerDetailVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var playerDetailScrollView: UIScrollView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var team: UILabel!
    @IBOutlet weak var jersey: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var born: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var school: UILabel!
    @IBOutlet weak var experience: UILabel!
    @IBOutlet weak var drafted: UILabel!
    @IBOutlet weak var ppg: UILabel!
    @IBOutlet weak var apg: UILabel!
    @IBOutlet weak var rpg: UILabel!
    
    var detailPlayer: Player?
    var teamID: String?
    var playerHeadshotURL: String?
    var playerID: String?
    var playerBirthdateFormatted: String?
    var playerInfoURL: String?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var use_real_images: String?
    var isDarkMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseSetup()
        defaultsChanged()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    @objc func defaultsChanged(){
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            updateToDarkTheme()
        } else {
            updateToLightTheme()
        }
    }
    
    func updateToDarkTheme(){
        nameLabel.textColor = .white
        teamLabel.textColor = .white
        jerseyLabel.textColor = .white
        positionLabel.textColor = .white
        birthdateLabel.textColor = .white
        heightLabel.textColor = .white
        weightLabel.textColor = .white
        schoolLabel.textColor = .white
        experienceLabel.textColor = .white
        draftedLabel.textColor = .white
        ppgLabel.textColor = .white
        apgLabel.textColor = .white
        rpgLabel.textColor = .white
        baseView.backgroundColor = .black
        playerDetailScrollView.backgroundColor = .black
        navigationController?.view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        self.playerDetailScrollView.indicatorStyle = .white;
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        nameLabel.textColor = .black
        teamLabel.textColor = .black
        jerseyLabel.textColor = .black
        positionLabel.textColor = .black
        birthdateLabel.textColor = .black
        heightLabel.textColor = .black
        weightLabel.textColor = .black
        schoolLabel.textColor = .black
        experienceLabel.textColor = .black
        draftedLabel.textColor = .black
        ppgLabel.textColor = .black
        apgLabel.textColor = .black
        rpgLabel.textColor = .black
        baseView.backgroundColor = .white
        playerDetailScrollView.backgroundColor = .white
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        self.playerDetailScrollView.indicatorStyle = .default;
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func start() {
        firebaseSetup()
        checkForPlayerID()
        fetchPlayer()
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
    
    func checkForPlayerID() {
        if let playerID = self.playerID {
            playerInfoURL = "\(PlayerInfoBaseURL)?\(PlayerID)\(playerID)"
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "Fatal Error", message: "PlayerID Required")
        }
    }
    
    func fetchPlayer() {
        self.hideUI(value: true)
        if CheckInternet.connection() {
            DispatchQueue.main.async {
                self.playerDetailScrollView.isUserInteractionEnabled = false
                self.hideUI(value: true)
                self.setupActivityIndicator()
                self.activityIndicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async {
                let detailPlayerApi = PlayerApi()
                if let playerInfoURL = self.playerInfoURL {
                    detailPlayerApi.getPlayers(url: playerInfoURL) { (detailPlayer, error)  in
                        if error == nil {
                            DispatchQueue.main.async {
                                if let player = detailPlayer {
                                    self.detailPlayer = player
                                    self.showDetail(player: player)
                                }
                                self.hideUI(value: false)
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.removeFromSuperview()
                                self.playerDetailScrollView.isUserInteractionEnabled = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                                    self.navigationController?.popToRootViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func hideUI(value: Bool) {
        playerDetailScrollView.isHidden = value
    }
    
    func showDetail(player: Player) {
        DispatchQueue.main.async {
            self.navigationItem.title = player.name
            if let ID = player.ID, let teamID = player.teamID {
                if ID == "" {
                    self.headshotImageView.displayPlaceholderImage()
                } else {
                    if self.use_real_images == "false" {
                        self.headshotImageView.displayPlaceholderImage()
                    } else {
                        self.playerHeadshotURL = "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/\(teamID)/\(PictureYear)/260x190/\(ID).png"
                        if self.playerHeadshotURL != nil {
                            self.headshotImageView.loadImageUsingCache(withURL: self.playerHeadshotURL ?? "")
                            if self.headshotImageView.image == nil {
                                self.headshotImageView.displayPlaceholderImage()
                            }
                        }
                    }
                }
            } else {
                self.headshotImageView.displayPlaceholderImage()
            }
            
            if let name = player.name {
                if name == "" || name == " " {
                    self.nameLabel.text = "N/A"
                } else {
                    self.nameLabel.text = name
                }
            } else {
                self.nameLabel.text = "N/A"
            }
            
            if let teamCity = player.teamCity, let teamName = player.teamName {
                if teamCity == "" || teamCity == " " {
                    self.teamLabel.text = "N/A"
                } else {
                    self.teamLabel.text = "\(teamCity) \(teamName)"
                }
            } else {
                self.teamLabel.text = "N/A"
            }
            
            if let jerseyNumber = player.jerseyNumber {
                if jerseyNumber == "" || jerseyNumber == " " {
                    self.jerseyLabel.text = "N/A"
                } else {
                    self.jerseyLabel.text = "#\(jerseyNumber)"
                }
            } else {
                self.jerseyLabel.text = "N/A"
            }
            
            if let position = player.position {
                if position == "" || position == " " {
                    self.positionLabel.text = "N/A"
                } else {
                    self.positionLabel.text = position
                }
            } else {
                self.positionLabel.text = "N/A"
            }
            
            if let birthdate = self.playerBirthdateFormatted {
                if birthdate == "" || birthdate == " " {
                    self.birthdateLabel.text = "N/A"
                } else {
                    self.birthdateLabel.text = "\(birthdate.lowercased().capitalized) (\(self.calcAge(birthday: birthdate)) years)"
                }
            } else {
                self.birthdateLabel.text = "N/A"
            }
            
            if let height = player.height {
                if height == "" || height == " " {
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
                if weight == "" || weight == " " {
                    self.weightLabel.text = "N/A"
                } else {
                    self.weightLabel.text = "\(weight) lbs"
                }
            } else {
                self.weightLabel.text = "N/A"
            }
            
            if let school = player.school {
                if school == "" || school == " " {
                    self.schoolLabel.text = "N/A"
                } else {
                    self.schoolLabel.text = school
                }
            } else {
                self.schoolLabel.text = "N/A"
            }
            
            if let experience = player.experience {
                if experience == "" || experience == " " {
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
                if draftYear == "" || draftRound == "" || draftPick == "" || draftYear == " " || draftRound == " " || draftPick == " " {
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
                if ppg == "" || ppg == " " {
                    self.ppgLabel.text = "N/A"
                } else {
                    let ppg = (ppg as NSString).doubleValue
                    self.ppgLabel.text = String(ppg.rounded(toPlaces: 1))
                }
            } else {
                self.ppgLabel.text = "N/A"
            }
            
            if let apg = player.apg {
                if apg == "" || apg == " " {
                    self.apgLabel.text = "N/A"
                } else {
                    let apg = (apg as NSString).doubleValue
                    self.apgLabel.text = String(apg.rounded(toPlaces: 1))
                }
            } else {
                self.apgLabel.text = "N/A"
            }
            
            if let rpg = player.rpg {
                if rpg == "" || rpg == " " {
                    self.rpgLabel.text = "N/A"
                } else {
                    let rpg = (rpg as NSString).doubleValue
                    self.rpgLabel.text = String(rpg.rounded(toPlaces: 1))
                }
            } else {
                self.rpgLabel.text = "N/A"
            }
        }
        
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            nameLabel.textColor = .white
            teamLabel.textColor = .white
            jerseyLabel.textColor = .white
            positionLabel.textColor = .white
            birthdateLabel.textColor = .white
            heightLabel.textColor = .white
            weightLabel.textColor = .white
            schoolLabel.textColor = .white
            experienceLabel.textColor = .white
            draftedLabel.textColor = .white
            ppgLabel.textColor = .white
            apgLabel.textColor = .white
            rpgLabel.textColor = .white
            playerDetailScrollView.backgroundColor = .black
            baseView.backgroundColor = .black
        } else {
            nameLabel.textColor = .black
            teamLabel.textColor = .black
            jerseyLabel.textColor = .black
            positionLabel.textColor = .black
            birthdateLabel.textColor = .black
            heightLabel.textColor = .black
            weightLabel.textColor = .black
            schoolLabel.textColor = .black
            experienceLabel.textColor = .black
            draftedLabel.textColor = .black
            ppgLabel.textColor = .black
            apgLabel.textColor = .black
            rpgLabel.textColor = .black
            playerDetailScrollView.backgroundColor = .white
            baseView.backgroundColor = .white
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
    
    @IBAction func reset(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

