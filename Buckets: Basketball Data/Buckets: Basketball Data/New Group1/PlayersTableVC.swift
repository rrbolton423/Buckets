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
    let refreshController = UIRefreshControl()
    
    @objc fileprivate func start() {
        tableView.addSubview(refreshController)
        refreshController.addTarget(self, action: #selector(start), for: .valueChanged)
        setupInfoBarButtonItem()
        setupSearchController()
        firebaseSetup()
        checkForTeamID()
        fetchPlayers()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            start()
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: true, completion: nil)
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
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        tableView.reloadData()
    }
    
    func firebaseSetup() {
        DispatchQueue.global(qos: .background).async {
            FirebaseConstants().setupAPP()
        }
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.gray
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
    
    func fetchPlayers() {
        if CheckInternet.connection() {
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = false
                self.unfilteredRoster = nil
                self.filteredRoster = nil
                self.tableView.reloadData()
                self.setupActivityIndicator()
                if (!self.refreshController.isRefreshing) {self.activityIndicator.startAnimating()}
            }
            DispatchQueue.global(qos: .background).async {
                let playersAPI = PlayersApi()
                if let teamRosterURL = self.teamRosterURL {
                    playersAPI.getPlayers(url: teamRosterURL) { (players) in
                        self.unfilteredRoster = players
                        let namesSorted = self.unfilteredRoster?.sorted { (initial, next) -> Bool in
                            return initial.lastName?.compare(next.lastName ?? "") == .orderedAscending
                        }
                        self.unfilteredRoster = namesSorted
                        self.filteredRoster = self.unfilteredRoster
                        DispatchQueue.main.async {
                            self.refreshController.endRefreshing()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.removeFromSuperview()
                            self.tableView.reloadData()
                            self.tableView.isUserInteractionEnabled = true
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = false
                self.refreshController.endRefreshing()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.navigationController?.popToRootViewController(animated: true)
                self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
            }
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
