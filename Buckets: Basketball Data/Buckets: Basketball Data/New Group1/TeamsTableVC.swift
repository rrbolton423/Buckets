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
    var teamToPass: StaticTeam?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var use_real_images: String?
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        firebaseSetup()
        loadTeams()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
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
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredTeamList = unfilteredTeamList?.filter { team in
                return (team.name?.lowercased().contains(searchText.lowercased()))!
            }
        } else {
            filteredTeamList = unfilteredTeamList
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
        FirebaseConstants().setupAPP()
        use_real_images = FirebaseConstants().getImages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTeamList?.count ?? 0
    }
    
    func parseTeamsFromJSONFile() -> [StaticTeam] {
        var resultArray = [StaticTeam]()
        guard let url = Bundle.main.url(forResource: "StaticTeams", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let JSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let jsonArray = JSON as? [[String: Any]] {
                for team in jsonArray {
                    let team = StaticTeam(dictionary: team)
                    resultArray.append(team)
                }
            }
        } catch {
            print(error)
        }
        return resultArray
    }
    
    func loadTeams(){
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        unfilteredTeamList = parseTeamsFromJSONFile()
        filteredTeamList = unfilteredTeamList
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as? TeamCell
        if let teamPic = filteredTeamList?[indexPath.row].picture {
            if use_real_images == "false" {
                cell?.teamLogo.image = UIImage(named: "placeholder.png")
            } else {
                cell?.teamLogo.image = UIImage(named: teamPic)
            }
        } else {
            cell?.teamLogo.image = UIImage(named: "placeholder.png")
        }
        if let teamName = filteredTeamList?[indexPath.row].name {
            cell?.teamName.text = teamName
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? TeamDetailVC
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            teamToPass = filteredTeamList?[(selectedIndexPath.row)]
            detailVC?.staticTeam = teamToPass
            let selectedCell = tableView.cellForRow(at: selectedIndexPath)
            detailVC?.detailImage = selectedCell?.imageView?.image
        }
    }
}
