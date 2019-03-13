//
//  PlayersTableVC.swift
//  Buckets - Basketball Info & Stats
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit

class PlayersTableVC: UITableViewController {
    var roster: [Players]?
    var selectedTeamID: String?
    var teamRosterURL: String?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        checkForTeamID()
        fetchPlayers()
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
                    self.roster = players
                    let namesSorted = self.roster?.sorted { (initial, next) -> Bool in
                        return initial.lastName?.compare(next.lastName ?? "") == .orderedAscending
                    }
                    self.roster = namesSorted
                }
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(title: "No Internet Connection", message: "Your device is not connected to the internet")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return roster?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as? PlayerCell
        if let playerName = roster?[indexPath.row].fullName, let jerseyNumber = roster?[indexPath.row].jerseyNumber {
            cell?.playerName.text = "#"+jerseyNumber + " " + playerName
        }
        if let position = roster?[indexPath.row].position {
            cell?.position.text = position
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
            if let playerID = roster?[(selectedIndexPath.row)].ID {
                detailVC?.playerID = playerID
            }
            if let birthdate = roster?[(selectedIndexPath.row)].birthdate {
                detailVC?.playerBirthdateFormatted = birthdate
            }
        }
    }
}
