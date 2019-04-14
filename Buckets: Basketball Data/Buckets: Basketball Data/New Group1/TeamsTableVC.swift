//
//  TeamsTableVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import Firebase

class TeamsTableVC: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var unfilteredTeamList: [StaticTeam]?
    var filteredTeamList: [StaticTeam]?
    var unfilteredFavoritesTeamList: [StaticTeam]? = []
    var filteredFavoritesTeamList: [StaticTeam]? = []
    var teamToPass: StaticTeam?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var use_real_images: String?
    let searchController = UISearchController(searchResultsController: nil)
    var teamToFavorite: StaticTeam?
    var teamToDelete: StaticTeam?
    var isFavoriteSelected: Bool = UserDefaults.standard.bool(forKey: "isFavoriteSelected")
    var store = DataStore.sharedInstance
    
    @objc func defaultsChanged(){
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            //dark theme enabled
            updateToDarkTheme()
            //isDarkMode = true
            print(isDarkMode)
            tableView.reloadData()
        } else {
            //dark theme disabled
            updateToLightTheme()
            //isDarkMode = false
            print(isDarkMode)
            tableView.reloadData()
        }
    }
    
    func updateToDarkTheme(){
        navigationController?.view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        self.searchController.searchBar.setTextColor(color: .white)
        self.tableView.indicatorStyle = .white
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = .black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        self.searchController.searchBar.setTextColor(color: .black)
        self.tableView.indicatorStyle = .default
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("Before \(filteredTeamList?.count)")
//        loadData()
//        start()
        FirebaseConstants().setupAPP()
        self.use_real_images = FirebaseConstants().getImages()
        defaultsChanged()
        if (self.isFavoriteSelected == false) {
            self.navigationItem.title = "All Teams"
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon")
        } else {
            self.navigationItem.title = "Favorite Teams"
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon_Filled")
        }
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
//        print("After \(filteredTeamList?.count)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        searchController.dismiss(animated: true, completion: nil)
    }
    
    @objc func start() {
        setupFavoriteBarButtonItem()
        //setupTrashBarButtonItem()
        setupSearchController()
        loadTeams()
    }
    
    func setupSearchController() {
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController;
        self.definesPresentationContext = true
    }
    
    func loadTeams(){
        self.tableView.isUserInteractionEnabled = false
        setupActivityIndicator()
        self.activityIndicator.startAnimating()
        unfilteredTeamList = parseTeamsFromJSONFile()
        filteredTeamList = unfilteredTeamList
        tableView.reloadData()
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        self.tableView.isUserInteractionEnabled = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        loadData()
        //start()
        defaultsChanged()
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            if isFavoriteSelected == false {
                filteredTeamList = unfilteredTeamList?.filter { team in
                    return (team.name?.lowercased().contains(searchText.lowercased()))!
                }
            } else {
                self.store.favoriteTeams = (unfilteredFavoritesTeamList?.filter { team in
                    return (team.name?.lowercased().contains(searchText.lowercased()))!
                    })!
            }
        } else {

            if isFavoriteSelected == false {
                filteredTeamList = unfilteredTeamList
            } else {
                self.store.favoriteTeams = unfilteredFavoritesTeamList!
            }
        }
        
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        tableView.reloadData()
    }
    
    func parseTeamsFromJSONFile() -> [StaticTeam] {
        FirebaseConstants().setupAPP()
        self.use_real_images = FirebaseConstants().getImages()
        var resultArray = [StaticTeam]()
        guard let url = Bundle.main.url(forResource: "StaticTeams", withExtension: "json") else { return [] }
        guard let url_placeholder = Bundle.main.url(forResource: "StaticTeamsPlaceholder", withExtension: "json") else { return [] }
        if self.use_real_images == "false" {
            do {
                let data = try Data(contentsOf: url_placeholder)
                let JSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let jsonArray = JSON as? [[String: Any]] {
                    for team in jsonArray {
                        let team = StaticTeam(dictionary: team)!
                        resultArray.append(team)
                    }
                }
            } catch {
                print(error)
            }
        } else {
            do {
                let data = try Data(contentsOf: url)
                let JSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let jsonArray = JSON as? [[String: Any]] {
                    for team in jsonArray {
                        let team = StaticTeam(dictionary: team)!
                        resultArray.append(team)
                    }
                }
            } catch {
                print(error)
            }
        }
        return resultArray.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.color = UIColor.gray
        self.view.addSubview(self.activityIndicator)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        
        switch(isFavoriteSelected)
        {
        case false:
    
            self.tableView.restore()
            returnValue = filteredTeamList?.count ?? 0
//            print(filteredTeamList?.count)
            break
            
        case true:
            
            if self.store.favoriteTeams.count == 0 {
//                self.searchController.searchBar.isUserInteractionEnabled = false
                self.tableView.setEmptyMessage("No favorite teams found")
            } else {
//                self.searchController.searchBar.isUserInteractionEnabled = true
                self.tableView.restore()
            }
            returnValue = self.store.favoriteTeams.count 
            print(self.store.favoriteTeams.count)
            break
        }
        return returnValue
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as? TeamCell
        cell?.backgroundColor = .clear
        
        switch(isFavoriteSelected)
        {
        case false:
//            if let teamPic = filteredTeamList?[indexPath.row].picture {
//                cell?.teamLogoImageView.image = UIImage(named: teamPic)
//            } else {
//                cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
//            }
            
            if self.use_real_images == "false" {
                switch filteredTeamList?[indexPath.row].name {
                case "Brooklyn Nets": cell?.teamLogoImageView.image = UIImage(named: "BKN_placeholder.png")
                case "Atlanta Hawks": cell?.teamLogoImageView.image = UIImage(named: "ATL_placeholder.png")
                case "Boston Celtics": cell?.teamLogoImageView.image = UIImage(named: "BOS_placeholder.png")
                case "Charlotte Hornets": cell?.teamLogoImageView.image = UIImage(named: "CHA_placeholder.png")
                case "Chicago Bulls": cell?.teamLogoImageView.image = UIImage(named: "CHI_placeholder.png")
                case "Cleveland Cavaliers": cell?.teamLogoImageView.image = UIImage(named: "CLE_placeholder.png")
                case "Dallas Mavericks": cell?.teamLogoImageView.image = UIImage(named: "DAL_placeholder.png")
                case "Denver Nuggets": cell?.teamLogoImageView.image = UIImage(named: "DEN_placeholder.png")
                case "Detroit Pistons": cell?.teamLogoImageView.image = UIImage(named: "DET_placeholder.png")
                case "Golden State Warriors": cell?.teamLogoImageView.image = UIImage(named: "GSW_placeholder.png")
                case "Houston Rockets": cell?.teamLogoImageView.image = UIImage(named: "HOU_placeholder.png")
                case "Indiana Pacers": cell?.teamLogoImageView.image = UIImage(named: "IND_placeholder.png")
                case "Los Angeles Clippers": cell?.teamLogoImageView.image = UIImage(named: "LAC_placeholder.png")
                case "Los Angeles Lakers": cell?.teamLogoImageView.image = UIImage(named: "LAL_placeholder.png")
                case "Memphis Grizzlies": cell?.teamLogoImageView.image = UIImage(named: "MEM_placeholder.png")
                case "Miami Heat": cell?.teamLogoImageView.image = UIImage(named: "MIA_placeholder.png")
                case "Milwaukee Bucks": cell?.teamLogoImageView.image = UIImage(named: "MIL_placeholder.png")
                case "Minnesota Timberwolves": cell?.teamLogoImageView.image = UIImage(named: "MIN_placeholder.png")
                case "New Orleans Pelicans": cell?.teamLogoImageView.image = UIImage(named: "NOP_placeholder.png")
                case "New York Knicks": cell?.teamLogoImageView.image = UIImage(named: "NYK_placeholder.png")
                case "Oklahoma City Thunder": cell?.teamLogoImageView.image = UIImage(named: "OKC_placeholder.png")
                case "Orlando Magic": cell?.teamLogoImageView.image = UIImage(named: "ORL_placeholder.png")
                case "Philadelphia 76ers": cell?.teamLogoImageView.image = UIImage(named: "PHI_placeholder.png")
                case "Phoenix Suns": cell?.teamLogoImageView.image = UIImage(named: "PHX_placeholder.png")
                case "Portland Trail Blazers": cell?.teamLogoImageView.image = UIImage(named: "POR_placeholder.png")
                case "Sacramento Kings": cell?.teamLogoImageView.image = UIImage(named: "SAC_placeholder.png")
                case "San Antonio Spurs": cell?.teamLogoImageView.image = UIImage(named: "SAS_placeholder.png")
                case "Toronto Raptors": cell?.teamLogoImageView.image = UIImage(named: "TOR_placeholder.png")
                case "Utah Jazz": cell?.teamLogoImageView.image = UIImage(named: "UTA_placeholder.png")
                case "Washington Wizards": cell?.teamLogoImageView.image = UIImage(named: "WAS_placeholder.png")
                default: cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
                }
                
            } else {
                switch filteredTeamList?[indexPath.row].name {
            case "Brooklyn Nets": cell?.teamLogoImageView.image = UIImage(named: "bkn.png")
            case "Atlanta Hawks": cell?.teamLogoImageView.image = UIImage(named: "atl.png")
            case "Boston Celtics": cell?.teamLogoImageView.image = UIImage(named: "bos.png")
            case "Charlotte Hornets": cell?.teamLogoImageView.image = UIImage(named: "cha.png")
            case "Chicago Bulls": cell?.teamLogoImageView.image = UIImage(named: "chi.png")
            case "Cleveland Cavaliers": cell?.teamLogoImageView.image = UIImage(named: "cle.png")
            case "Dallas Mavericks": cell?.teamLogoImageView.image = UIImage(named: "dal.png")
            case "Denver Nuggets": cell?.teamLogoImageView.image = UIImage(named: "den.png")
            case "Detroit Pistons": cell?.teamLogoImageView.image = UIImage(named: "det.png")
            case "Golden State Warriors": cell?.teamLogoImageView.image = UIImage(named: "gsw.png")
            case "Houston Rockets": cell?.teamLogoImageView.image = UIImage(named: "hou.png")
            case "Indiana Pacers": cell?.teamLogoImageView.image = UIImage(named: "ind.png")
            case "Los Angeles Clippers": cell?.teamLogoImageView.image = UIImage(named: "lac.png")
            case "Los Angeles Lakers": cell?.teamLogoImageView.image = UIImage(named: "lal.png")
            case "Memphis Grizzlies": cell?.teamLogoImageView.image = UIImage(named: "mem.png")
            case "Miami Heat": cell?.teamLogoImageView.image = UIImage(named: "mia.png")
            case "Milwaukee Bucks": cell?.teamLogoImageView.image = UIImage(named: "mil.png")
            case "Minnesota Timberwolves": cell?.teamLogoImageView.image = UIImage(named: "min.png")
            case "New Orleans Pelicans": cell?.teamLogoImageView.image = UIImage(named: "nop.png")
            case "New York Knicks": cell?.teamLogoImageView.image = UIImage(named: "nyk.png")
            case "Oklahoma City Thunder": cell?.teamLogoImageView.image = UIImage(named: "okc.png")
            case "Orlando Magic": cell?.teamLogoImageView.image = UIImage(named: "orl.png")
            case "Philadelphia 76ers": cell?.teamLogoImageView.image = UIImage(named: "phi.png")
            case "Phoenix Suns": cell?.teamLogoImageView.image = UIImage(named: "phx.png")
            case "Portland Trail Blazers": cell?.teamLogoImageView.image = UIImage(named: "por.png")
            case "Sacramento Kings": cell?.teamLogoImageView.image = UIImage(named: "sac.png")
            case "San Antonio Spurs": cell?.teamLogoImageView.image = UIImage(named: "sas.png")
            case "Toronto Raptors": cell?.teamLogoImageView.image = UIImage(named: "tor.png")
            case "Utah Jazz": cell?.teamLogoImageView.image = UIImage(named: "uta.png")
            case "Washington Wizards": cell?.teamLogoImageView.image = UIImage(named: "was.png")
            default: cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
                }
            }
            
            
            if let teamName = filteredTeamList?[indexPath.row].name {
                cell?.teamNameLabel.text = teamName
            }
            if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
                cell?.teamNameLabel.textColor = .white
            } else {
                cell?.teamNameLabel.textColor = .black
            }
            break
        case true:
//            if let teamPic = self.store.favoriteTeams[indexPath.row].picture {
//                cell?.teamLogoImageView.image = UIImage(named: teamPic)
//            } else {
//                cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
//            }
            
            if self.use_real_images == "false" {
                switch self.store.favoriteTeams[indexPath.row].name {
                case "Brooklyn Nets": cell?.teamLogoImageView.image = UIImage(named: "BKN_placeholder.png")
                case "Atlanta Hawks": cell?.teamLogoImageView.image = UIImage(named: "ATL_placeholder.png")
                case "Boston Celtics": cell?.teamLogoImageView.image = UIImage(named: "BOS_placeholder.png")
                case "Charlotte Hornets": cell?.teamLogoImageView.image = UIImage(named: "CHA_placeholder.png")
                case "Chicago Bulls": cell?.teamLogoImageView.image = UIImage(named: "CHI_placeholder.png")
                case "Cleveland Cavaliers": cell?.teamLogoImageView.image = UIImage(named: "CLE_placeholder.png")
                case "Dallas Mavericks": cell?.teamLogoImageView.image = UIImage(named: "DAL_placeholder.png")
                case "Denver Nuggets": cell?.teamLogoImageView.image = UIImage(named: "DEN_placeholder.png")
                case "Detroit Pistons": cell?.teamLogoImageView.image = UIImage(named: "DET_placeholder.png")
                case "Golden State Warriors": cell?.teamLogoImageView.image = UIImage(named: "GSW_placeholder.png")
                case "Houston Rockets": cell?.teamLogoImageView.image = UIImage(named: "HOU_placeholder.png")
                case "Indiana Pacers": cell?.teamLogoImageView.image = UIImage(named: "IND_placeholder.png")
                case "Los Angeles Clippers": cell?.teamLogoImageView.image = UIImage(named: "LAC_placeholder.png")
                case "Los Angeles Lakers": cell?.teamLogoImageView.image = UIImage(named: "LAL_placeholder.png")
                case "Memphis Grizzlies": cell?.teamLogoImageView.image = UIImage(named: "MEM_placeholder.png")
                case "Miami Heat": cell?.teamLogoImageView.image = UIImage(named: "MIA_placeholder.png")
                case "Milwaukee Bucks": cell?.teamLogoImageView.image = UIImage(named: "MIL_placeholder.png")
                case "Minnesota Timberwolves": cell?.teamLogoImageView.image = UIImage(named: "MIN_placeholder.png")
                case "New Orleans Pelicans": cell?.teamLogoImageView.image = UIImage(named: "NOP_placeholder.png")
                case "New York Knicks": cell?.teamLogoImageView.image = UIImage(named: "NYK_placeholder.png")
                case "Oklahoma City Thunder": cell?.teamLogoImageView.image = UIImage(named: "OKC_placeholder.png")
                case "Orlando Magic": cell?.teamLogoImageView.image = UIImage(named: "ORL_placeholder.png")
                case "Philadelphia 76ers": cell?.teamLogoImageView.image = UIImage(named: "PHI_placeholder.png")
                case "Phoenix Suns": cell?.teamLogoImageView.image = UIImage(named: "PHX_placeholder.png")
                case "Portland Trail Blazers": cell?.teamLogoImageView.image = UIImage(named: "POR_placeholder.png")
                case "Sacramento Kings": cell?.teamLogoImageView.image = UIImage(named: "SAC_placeholder.png")
                case "San Antonio Spurs": cell?.teamLogoImageView.image = UIImage(named: "SAS_placeholder.png")
                case "Toronto Raptors": cell?.teamLogoImageView.image = UIImage(named: "TOR_placeholder.png")
                case "Utah Jazz": cell?.teamLogoImageView.image = UIImage(named: "UTA_placeholder.png")
                case "Washington Wizards": cell?.teamLogoImageView.image = UIImage(named: "WAS_placeholder.png")
                default: cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
                }
                
            } else {
                switch self.store.favoriteTeams[indexPath.row].name {
                case "Brooklyn Nets": cell?.teamLogoImageView.image = UIImage(named: "bkn.png")
                case "Atlanta Hawks": cell?.teamLogoImageView.image = UIImage(named: "atl.png")
                case "Boston Celtics": cell?.teamLogoImageView.image = UIImage(named: "bos.png")
                case "Charlotte Hornets": cell?.teamLogoImageView.image = UIImage(named: "cha.png")
                case "Chicago Bulls": cell?.teamLogoImageView.image = UIImage(named: "chi.png")
                case "Cleveland Cavaliers": cell?.teamLogoImageView.image = UIImage(named: "cle.png")
                case "Dallas Mavericks": cell?.teamLogoImageView.image = UIImage(named: "dal.png")
                case "Denver Nuggets": cell?.teamLogoImageView.image = UIImage(named: "den.png")
                case "Detroit Pistons": cell?.teamLogoImageView.image = UIImage(named: "det.png")
                case "Golden State Warriors": cell?.teamLogoImageView.image = UIImage(named: "gsw.png")
                case "Houston Rockets": cell?.teamLogoImageView.image = UIImage(named: "hou.png")
                case "Indiana Pacers": cell?.teamLogoImageView.image = UIImage(named: "ind.png")
                case "Los Angeles Clippers": cell?.teamLogoImageView.image = UIImage(named: "lac.png")
                case "Los Angeles Lakers": cell?.teamLogoImageView.image = UIImage(named: "lal.png")
                case "Memphis Grizzlies": cell?.teamLogoImageView.image = UIImage(named: "mem.png")
                case "Miami Heat": cell?.teamLogoImageView.image = UIImage(named: "mia.png")
                case "Milwaukee Bucks": cell?.teamLogoImageView.image = UIImage(named: "mil.png")
                case "Minnesota Timberwolves": cell?.teamLogoImageView.image = UIImage(named: "min.png")
                case "New Orleans Pelicans": cell?.teamLogoImageView.image = UIImage(named: "nop.png")
                case "New York Knicks": cell?.teamLogoImageView.image = UIImage(named: "nyk.png")
                case "Oklahoma City Thunder": cell?.teamLogoImageView.image = UIImage(named: "okc.png")
                case "Orlando Magic": cell?.teamLogoImageView.image = UIImage(named: "orl.png")
                case "Philadelphia 76ers": cell?.teamLogoImageView.image = UIImage(named: "phi.png")
                case "Phoenix Suns": cell?.teamLogoImageView.image = UIImage(named: "phx.png")
                case "Portland Trail Blazers": cell?.teamLogoImageView.image = UIImage(named: "por.png")
                case "Sacramento Kings": cell?.teamLogoImageView.image = UIImage(named: "sac.png")
                case "San Antonio Spurs": cell?.teamLogoImageView.image = UIImage(named: "sas.png")
                case "Toronto Raptors": cell?.teamLogoImageView.image = UIImage(named: "tor.png")
                case "Utah Jazz": cell?.teamLogoImageView.image = UIImage(named: "uta.png")
                case "Washington Wizards": cell?.teamLogoImageView.image = UIImage(named: "was.png")
                default: cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
                }
            }
            
            
            if let teamName = self.store.favoriteTeams[indexPath.row].name {
                cell?.teamNameLabel.text = teamName
            }
            if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
                cell?.teamNameLabel.textColor = .white
            } else {
                cell?.teamNameLabel.textColor = .black
            }
            break
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favorite: UITableViewRowAction
        let delete: UITableViewRowAction
        let row = indexPath.row
        
        switch(isFavoriteSelected)
        {
            
        case false:
            teamToFavorite = self.filteredTeamList?[row]
            teamToDelete = self.filteredTeamList?[row]
            print("Favorite: \(teamToFavorite!)")
            print("Delete: \(teamToDelete!)")
            favorite = UITableViewRowAction(style: .default, title: "Favorite") { (action, indexPath) in
                self.saveData(item: self.teamToFavorite!)
//                tableView.reloadData()
                self.getFavoriteAction()
            }
            favorite.backgroundColor = hexStringToUIColor(hex: "#5A5ED0")
//            delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//                print(self.unfilteredFavoritesTeamList ?? "Empty")
//                self.deleteData(item: self.teamToDelete!)
////                tableView.reloadData()
//                self.getDeleteAction()
//            }
//            delete.backgroundColor = hexStringToUIColor(hex: "#FC3D39")
            return [favorite]
            
        case true:
            teamToFavorite = self.store.favoriteTeams[row]
            teamToDelete = self.store.favoriteTeams[row]
//            favorite = UITableViewRowAction(style: .default, title: "Favorite") { (action, indexPath) in
//                self.saveData(item: self.teamToFavorite!)
////                tableView.reloadData()
//                self.getFavoriteAction()
//            }
//            favorite.backgroundColor = hexStringToUIColor(hex: "#5A5ED0")
            delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                self.deleteData(item: self.store.favoriteTeams[indexPath.row])
                tableView.reloadData()
                self.getDeleteAction()
            }
            delete.backgroundColor = hexStringToUIColor(hex: "#FC3D39")
            return [delete]
            
        }
        //return [delete, favorite]
    }
    
    @objc func deleteAllFavorites() {
        if (self.isFavoriteSelected == true) {
            deleteAllData()
            loadData()
            start()
            defaultsChanged()
            //self.isFavoriteSelected = !isFavoriteSelected
            //navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon_Filled")
        }
        print(isFavoriteSelected)
        self.store.favoriteTeams.removeAll()
        tableView.reloadData()
    }
    
    @objc func showFavorites() {
        if (self.isFavoriteSelected == true) {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            loadData()
            start()
            defaultsChanged()
            self.isFavoriteSelected = !isFavoriteSelected
            UserDefaults.standard.set(self.isFavoriteSelected, forKey: "isFavoriteSelected")
            self.navigationItem.title = "All Teams"
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon")
        } else {
            setupTrashBarButtonItem()
            loadData()
            start()
            defaultsChanged()
            self.isFavoriteSelected = !isFavoriteSelected
            UserDefaults.standard.set(self.isFavoriteSelected, forKey: "isFavoriteSelected")
            self.navigationItem.title = "Favorite Teams"
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon_Filled")
        }
        print(isFavoriteSelected)
        tableView.reloadData()
    }
    
    func setupFavoriteBarButtonItem() {
        let favoriteItem = UIBarButtonItem(image: UIImage(named: "star_Icon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(showFavorites))
        navigationItem.rightBarButtonItem = favoriteItem
    }
    
    func setupTrashBarButtonItem() {
        let trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAllData))
        navigationItem.leftBarButtonItem = trashItem
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func getFavoriteAction() {
        let alert = UIAlertController(title: nil, message: "The \(teamToFavorite?.name ?? "") have been added to your favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func getDeleteAction() {
        let alert = UIAlertController(title: nil, message: "The \(teamToFavorite?.name ?? "") have been removed from your favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func favoriteAlreadyAddedAction() {
        let alert = UIAlertController(title: nil, message: "The \(teamToFavorite?.name ?? "") are a favorite", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? TeamDetailVC
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            print(selectedIndexPath)
            
            if isFavoriteSelected == false {
                teamToPass = filteredTeamList?[(selectedIndexPath.row)]
                detailVC?.staticTeam = teamToPass
                let selectedCell = tableView.cellForRow(at: selectedIndexPath)
                detailVC?.detailImage = selectedCell?.imageView?.image
            } else {
                print(self.store.favoriteTeams)
                teamToPass = self.store.favoriteTeams[(selectedIndexPath.row)]
                detailVC?.staticTeam = teamToPass
                let selectedCell = tableView.cellForRow(at: selectedIndexPath)
                detailVC?.detailImage = selectedCell?.imageView?.image
            }
           }
        }
    
    var filePath: String {
        //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
        let manager = FileManager.default
        //2 - this returns an array of urls from our documentDirectory and we take the first path
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
//        print("this is the url path in the documentDirectory \(url)")
        //3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
        return (url!.appendingPathComponent("Data").path)
    }
    
    @objc func favoriteAlreadyDeletedAction() {
        let alert = UIAlertController(title: nil, message: "The \(teamToDelete?.name ?? "") are not a favorite", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func allFavoritesAlreadyDeletedAction() {
        let alert = UIAlertController(title: nil, message: "There are no favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func getAllFavoritesDeletedAction() {
        let alert = UIAlertController(title: nil, message: "Your favorites have been deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveData(item: StaticTeam) {
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
            self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            print(ourData)
        }
        let results = self.store.favoriteTeams.filter { $0.name == teamToFavorite?.name }
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
        let results = self.store.favoriteTeams.filter { $0.name == teamToDelete?.name }
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
            let results = self.store.favoriteTeams.filter { $0.name == teamToDelete?.name }
            let exists = results.isEmpty == false
            
            if exists == true {
//                print(item.name)
                if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
                    self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
                    print(ourData)
                }
                let results = self.store.favoriteTeams.filter { $0.name == item.name }
                let exists = results.isEmpty == false
                
                
                if exists == true {
                    let itemName = item.name!
                    if let index = self.store.favoriteTeams.firstIndex(where: {$0.name == itemName}) {
                        //print(self.store.favoriteTeams.remove(at: index))
                        print("INDEX IS \(index)")
                        self.store.favoriteTeams.remove(at: index)
                        tableView.reloadData()
                    }
                }
            }
        }
        //4 - nskeyedarchiver is going to look in every shopping list class and look for encode function and is going to encode our data and save it to our file path.  This does everything for encoding and decoding.
        //5 - archive root object saves our array of shopping items (our data) to our filepath url
        NSKeyedArchiver.archiveRootObject(self.store.favoriteTeams, toFile: filePath)
        getDeleteAction()
    }
    
    @objc func deleteAllData() {
        print(self.store.favoriteTeams.count)
        if self.store.favoriteTeams.count != 0 {
            self.store.favoriteTeams.removeAll()
            tableView.reloadData()
            //4 - nskeyedarchiver is going to look in every shopping list class and look for encode function and is going to encode our data and save it to our file path.  This does everything for encoding and decoding.
            //5 - archive root object saves our array of shopping items (our data) to our filepath url
            NSKeyedArchiver.archiveRootObject(self.store.favoriteTeams, toFile: filePath)
            getAllFavoritesDeletedAction()
        } else {
            allFavoritesAlreadyDeletedAction()
            return
        }
    }
    
    private func loadData() {
        //6 - if we can get back our data from our archives (load our data), get our data along our file path and cast it as an array of ShoppingItems
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [StaticTeam] {
            self.store.favoriteTeams = ourData.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            self.unfilteredFavoritesTeamList = self.store.favoriteTeams
            
        }
    }
}
