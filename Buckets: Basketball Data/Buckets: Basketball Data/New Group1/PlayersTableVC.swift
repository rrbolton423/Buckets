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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        firebaseSetup()
        setupActivityIndicator()
        checkForTeamID()
        fetchPlayers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func firebaseSetup() {
        FirebaseConstants().setupAPP()
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
    }
    
    func checkForTeamID() {
        if let teamID = self.selectedTeamID {
            teamRosterURL = "\(TeamRosterBaseURL)?\(LeagueID)&\(Season)&\(IsOnlyCurrentSeason)&\(TeamID)\(teamID)"
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "Fatal Error", message: "TeamID Required")
        }
    }
    
    func fetchPlayers() {
        if CheckInternet.connection() {
            activityIndicator.startAnimating()
            let playersAPI = PlayersApi()
            if let teamRosterURL = self.teamRosterURL {
                playersAPI.getPlayers(url: teamRosterURL) { (players) in
                    self.unfilteredRoster = players
                    let namesSorted = self.unfilteredRoster?.sorted { (initial, next) -> Bool in
                        return initial.lastName?.compare(next.lastName ?? "") == .orderedAscending
                    }
                    self.unfilteredRoster = namesSorted
                    self.filteredRoster = self.unfilteredRoster
                    self.tableView.reloadData()
                }
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
        }
    }
    
    // MARK: - Table view data source
    
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
        
        if let nbaTeams = filteredRoster {
            if let playerName = nbaTeams[indexPath.row].fullName, let jerseyNumber = nbaTeams[indexPath.row].jerseyNumber {
                cell?.playerName.text = "#"+jerseyNumber + " " + playerName
            }
            if let position = nbaTeams[indexPath.row].position {
                cell?.position.text = position
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                self.activityIndicator.removeFromSuperview()
            }
        }
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
