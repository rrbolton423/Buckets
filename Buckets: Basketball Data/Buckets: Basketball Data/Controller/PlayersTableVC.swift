//
//  PlayersTableVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit

class PlayersTableVC: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var unfilteredRoster: [Players]?
    var filteredRoster: [Players]?
    var selectedTeamID: String?
    var teamRosterURL: String?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    let searchController = UISearchController(searchResultsController: nil)
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
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.definesPresentationContext = true
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
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        searchController.searchBar.setMagnifyingGlassColorTo(color: hexStringToUIColor(hex: "#9A9A9E"))
        self.tableView.indicatorStyle = .white
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = .black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.activityIndicator.color = UIColor.gray
        self.activityIndicator.assignColor(.white)
    }
    
    func updateToLightTheme() {
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        searchController.searchBar.setMagnifyingGlassColorTo(color: hexStringToUIColor(hex: "#9A9A9E"))
        self.tableView.indicatorStyle = .default;
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.activityIndicator.color = UIColor.gray
        self.activityIndicator.assignColor(.black)
    }
    
    @objc func start() {
        setupSearchController()
        firebaseSetup()
        checkForTeamID()
        fetchPlayers()
    }
    
    func setupSearchController() {
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController;
        self.definesPresentationContext = true
    }
    
    func firebaseSetup() {
        DispatchQueue.global(qos: .background).async {
            FirebaseConstants().setupAPP()
        }
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.white
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            self.activityIndicator.assignColor(.white)
        } else {
            self.activityIndicator.assignColor(.black)
        }
        self.view.addSubview(self.activityIndicator)
    }
    
    func checkForTeamID() {
        if let teamID = self.selectedTeamID {
            teamRosterURL = "\(TeamRosterBaseURL)?\(LeagueID)&\(Season)&\(IsOnlyCurrentSeason)&\(TeamID)\(teamID)"
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "Fatal Error", message: "TeamID Required")
        }
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
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredRoster = unfilteredRoster?.filter { player in
                return (player.fullName?.lowercased().contains(searchText.lowercased()))!
            }
        } else {
            filteredRoster = unfilteredRoster
        }
        tableView.reloadData()
    }
    
    func fetchPlayers() {
        if CheckInternet.connection() {
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = false
                self.unfilteredRoster = nil
                self.filteredRoster = nil
                self.tableView.reloadData()
                self.setupActivityIndicator()
                self.activityIndicator.startAnimating()
            }
            DispatchQueue.global(qos: .background).async {
                let playersAPI = PlayersApi()
                if let teamRosterURL = self.teamRosterURL {
                    playersAPI.getPlayers(url: teamRosterURL) { players, error in
                        if error == nil {
                            self.unfilteredRoster = players
                            let namesSorted = self.unfilteredRoster?.sorted { (initial, next) -> Bool in
                                return initial.lastName?.compare(next.lastName ?? "") == .orderedAscending
                            }
                            self.unfilteredRoster = namesSorted
                            self.filteredRoster = self.unfilteredRoster
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.removeFromSuperview()
                                self.tableView.isUserInteractionEnabled = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.tableView.isUserInteractionEnabled = false
                                self.filteredRoster = nil
                                self.tableView.reloadData()
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
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = false
                self.filteredRoster = nil
                self.tableView.reloadData()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRoster?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as? PlayerCell
        cell?.backgroundColor = .clear
        if let nbaTeams = filteredRoster {
            if let playerName = nbaTeams[indexPath.row].fullName, let jerseyNumber = nbaTeams[indexPath.row].jerseyNumber {
                if jerseyNumber == "" || jerseyNumber == " " {
                    cell?.playerNameLabel.text = playerName
                } else {
                    cell?.playerNameLabel.text = "#"+jerseyNumber + " " + playerName
                }
            }
            if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
                cell?.playerNameLabel.textColor = .white
                cell?.setDisclosure(toColour: .white)
            } else {
                cell?.playerNameLabel.textColor = .black
                cell?.setDisclosure(toColour: .black)
            }
            if let position = nbaTeams[indexPath.row].position {
                cell?.positionLabel.text = position
            }
        }
        return cell ?? UITableViewCell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? PlayerDetailVC
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            if let playerID = filteredRoster?[(selectedIndexPath.row)].ID {
                detailVC?.playerID = playerID
            }
            if let birthdate = filteredRoster?[(selectedIndexPath.row)].birthdate {
                detailVC?.playerBirthdateFormatted = birthdate
            }
        }
    }
}
