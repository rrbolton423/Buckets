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
    @IBOutlet weak var teamDetailScrollView: UIScrollView!
    @IBOutlet weak var playersButton: UIButton!
    @IBOutlet weak var founded: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var conference: UILabel!
    @IBOutlet weak var division: UILabel!
    @IBOutlet weak var record: UILabel!
    @IBOutlet weak var conferenceRank: UILabel!
    @IBOutlet weak var divisionRank: UILabel!
    @IBOutlet weak var baseView: UIView!
    
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
    var isDarkMode: Bool = false
    var store = DataStore.sharedInstance
    var isFavoriteSelected: Bool = false
    
    @objc func defaultsChanged(){
        var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            //dark theme enabled
            updateToDarkTheme()
            //isDarkMode = true
            print(isDarkMode)
        } else {
            //dark theme disabled
            updateToLightTheme()
            //isDarkMode = false
            print(isDarkMode)
        }
    }
    
    func updateToDarkTheme(){
        navigationController?.navigationBar.barStyle = .black
        self.teamDetailScrollView.indicatorStyle = .white;
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        navigationController?.navigationBar.barStyle = .default
        self.teamDetailScrollView.indicatorStyle = .default;
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func start() {
        setupFavoriteBarButtonItem()
        firebaseSetup()
        checkForTeamID()
        fetchRoster()
    }
    
    func checkIfTeamIsFavorite() {
        
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
            self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            print(ourData)
        }
        let results = self.store.favoriteTeams.filter { $0.name == staticTeam?.name }
        let exists = results.isEmpty == false
        print(exists)
        
        
        if exists == true {
            print("is a favorite")
            self.isFavoriteSelected = true
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon_Filled")
        } else {
            print("not a favorite")
            self.isFavoriteSelected = false
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
        checkIfTeamIsFavorite()
        defaultsChanged()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func checkForTeamID() {
        if let teamID = self.staticTeam?.ID {
            teamInfoURL = "\(TeamInfoBaseURL)?\(Season)&\(TeamID)\(teamID)&\(LeagueID)&\(SeasonType)"
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "Fatal Error", message: "TeamID Required")
        }
    }
    
    func fetchRoster() {
        self.hideUI(value: true)
        if CheckInternet.connection() {
            DispatchQueue.main.async {
                self.teamDetailScrollView.isUserInteractionEnabled = false
                self.setupActivityIndicator()
                self.activityIndicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async {
                let teamApi = TeamAPI()
                if let teamInfoURL = self.teamInfoURL {
                    teamApi.getTeamInfo(url: teamInfoURL) { (detailTeam) in
                        DispatchQueue.main.async {
                            self.teamToPass = detailTeam
                            self.showInfoDetail(team: detailTeam)
                            self.hideUI(value: false)
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.removeFromSuperview()
                            self.teamDetailScrollView.isUserInteractionEnabled = true
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
        teamDetailScrollView.isHidden = value
    }
    
    func showInfoDetail(team: DetailTeam?) {
        if let city = team?.city, let name = team?.name {
            if name == "" {
                self.teamNameLabel.text = "N/A"
            } else {
                self.teamNameLabel.text = "\(city) \(name)"
                self.navigationItem.title = "\(city) \(name)"
                if self.use_real_images == "false" {
                    switch name {
                    case "Nets": self.teamImage = UIImage(named: "BKN_placeholder.png")
                    case "Hawks": self.teamImage = UIImage(named: "ATL_placeholder.png")
                    case "Celtics": self.teamImage = UIImage(named: "BOS_placeholder.png")
                    case "Hornets": self.teamImage = UIImage(named: "CHA_placeholder.png")
                    case "Bulls": self.teamImage = UIImage(named: "CHI_placeholder.png")
                    case "Cavaliers": self.teamImage = UIImage(named: "CLE_placeholder.png")
                    case "Mavericks": self.teamImage = UIImage(named: "DAL_placeholder.png")
                    case "Nuggets": self.teamImage = UIImage(named: "DEN_placeholder.png")
                    case "Pistons": self.teamImage = UIImage(named: "DET_placeholder.png")
                    case "Warriors": self.teamImage = UIImage(named: "GSW_placeholder.png")
                    case "Rockets": self.teamImage = UIImage(named: "HOU_placeholder.png")
                    case "Pacers": self.teamImage = UIImage(named: "IND_placeholder.png")
                    case "Clippers": self.teamImage = UIImage(named: "LAC_placeholder.png")
                    case "Lakers": self.teamImage = UIImage(named: "LAL_placeholder.png")
                    case "Grizzlies": self.teamImage = UIImage(named: "MEM_placeholder.png")
                    case "Heat": self.teamImage = UIImage(named: "MIA_placeholder.png")
                    case "Bucks": self.teamImage = UIImage(named: "MIL_placeholder.png")
                    case "Timberwolves": self.teamImage = UIImage(named: "MIN_placeholder.png")
                    case "Pelicans": self.teamImage = UIImage(named: "NOP_placeholder.png")
                    case "Knicks": self.teamImage = UIImage(named: "NYK_placeholder.png")
                    case "Thunder": self.teamImage = UIImage(named: "OKC_placeholder.png")
                    case "Magic": self.teamImage = UIImage(named: "ORL_placeholder.png")
                    case "76ers": self.teamImage = UIImage(named: "PHI_placeholder.png")
                    case "Suns": self.teamImage = UIImage(named: "PHX_placeholder.png")
                    case "Trail Blazers": self.teamImage = UIImage(named: "POR_placeholder.png")
                    case "Kings": self.teamImage = UIImage(named: "SAC_placeholder.png")
                    case "Spurs": self.teamImage = UIImage(named: "SAS_placeholder.png")
                    case "Raptors": self.teamImage = UIImage(named: "TOR_placeholder.png")
                    case "Jazz": self.teamImage = UIImage(named: "UTA_placeholder.png")
                    case "Wizards": self.teamImage = UIImage(named: "WAS_placeholder.png")
                    default: self.teamImage = UIImage(named: "placeholder.png")
                    }
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
        
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            //cell.homeScoreLabel.textColor = .white
            baseView.backgroundColor = .black
            teamNameLabel.textColor = .white
            teamYearFoundedLabel.textColor = .white
            teamCityLabel.textColor = .white
            teamConferenceLabel.textColor = .white
            teamDivisionLabel.textColor = .white
            teamRecordLabel.textColor = .white
            teamConferenceRankLabel.textColor = .white
            teamDivisionRankLabel.textColor = .white
            teamDetailScrollView.backgroundColor = .black
            //playersButton.textColor = .white
        } else {
            baseView.backgroundColor = .white
            teamNameLabel.textColor = .black
            teamYearFoundedLabel.textColor = .black
            teamCityLabel.textColor = .black
            teamConferenceLabel.textColor = .black
            teamDivisionLabel.textColor = .black
            teamRecordLabel.textColor = .black
            teamConferenceRankLabel.textColor = .black
            teamDivisionRankLabel.textColor = .black
            teamDetailScrollView.backgroundColor = .white
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? PlayersTableVC
        detailVC?.selectedTeamID = teamToPass?.ID
    }
    
    @objc func showFavorites() {
        if (self.isFavoriteSelected == true) {
            self.isFavoriteSelected = !isFavoriteSelected
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon")
            deleteData(item: staticTeam!)
        } else {
            self.isFavoriteSelected = !isFavoriteSelected
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon_Filled")
            saveData(item: staticTeam!)
        }
        print(isFavoriteSelected)
    }
    
    func setupFavoriteBarButtonItem() {
        let favoriteItem = UIBarButtonItem(image: UIImage(named: "star_Icon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(showFavorites))
        navigationItem.rightBarButtonItem = favoriteItem
    }
    
    @objc func getFavoriteAction() {
        let alert = UIAlertController(title: nil, message: "The \(staticTeam?.name ?? "") have been added to your favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func favoriteAlreadyAddedAction() {
        let alert = UIAlertController(title: nil, message: "The \(staticTeam?.name ?? "") is a favorite", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var filePath: String {
        //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
        let manager = FileManager.default
        //2 - this returns an array of urls from our documentDirectory and we take the first path
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        print("this is the url path in the documentDirectory \(url)")
        //3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
        return (url!.appendingPathComponent("Data").path)
    }
    
    func saveData(item: StaticTeam) {
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
            self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            print(ourData)
        }
        let results = self.store.favoriteTeams.filter { $0.name == staticTeam?.name }
        let exists = results.isEmpty == false
        print(exists)
        if exists == true {
            favoriteAlreadyAddedAction()
            return
        } else {
            self.store.favoriteTeams.append(item)
            
            //4 - nskeyedarchiver is going to look in every shopping list class and look for encode function and is going to encode our data and save it to our file path.  This does everything for encoding and decoding.
            //5 - archive root object saves our array of shopping items (our data) to our filepath url
            NSKeyedArchiver.archiveRootObject(self.store.favoriteTeams, toFile: filePath)
            getFavoriteAction()
        }
    }
    
    func deleteData(item: StaticTeam) {
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
            self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            print(ourData)
        }
        let results = self.store.favoriteTeams.filter { $0.name == staticTeam?.name }
        let exists = results.isEmpty == false
        print(exists)
        if exists == false {
            favoriteAlreadyDeletedAction()
            return
        } else {
            if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
                self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
                print(ourData)
            }
            let results = self.store.favoriteTeams.filter { $0.name == staticTeam?.name }
            let exists = results.isEmpty == false
            
            if exists == true {
                let itemName = item.name!
                if let index = self.store.favoriteTeams.firstIndex(where: {$0.name == itemName}) {
                    self.store.favoriteTeams.remove(at: index)
                }
            }
        }
        //4 - nskeyedarchiver is going to look in every shopping list class and look for encode function and is going to encode our data and save it to our file path.  This does everything for encoding and decoding.
        //5 - archive root object saves our array of shopping items (our data) to our filepath url
        NSKeyedArchiver.archiveRootObject(self.store.favoriteTeams, toFile: filePath)
        getDeleteAction()
    }
    
    @objc func getDeleteAction() {
        let alert = UIAlertController(title: nil, message: "The \(staticTeam?.name ?? "") have been removed from your favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func favoriteAlreadyDeletedAction() {
        let alert = UIAlertController(title: nil, message: "The \(staticTeam?.name ?? "") is not a favorite", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loadData() {
        //6 - if we can get back our data from our archives (load our data), get our data along our file path and cast it as an array of ShoppingItems
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
            self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
        }
    }
}
