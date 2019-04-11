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
    var favoritesTeamList: [StaticTeam]? = []
    var teamToPass: StaticTeam?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var use_real_images: String?
    let searchController = UISearchController(searchResultsController: nil)
    
    
    @objc func defaultsChanged(){
        var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
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
        self.searchController.searchBar.barStyle = .blackOpaque
        self.tableView.indicatorStyle = .white
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = .black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        self.searchController.searchBar.barStyle = .default
        self.tableView.indicatorStyle = .default;
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrive favorites
        let decoded  = UserDefaults.standard.object(forKey: "favorites") as! Data
        let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [StaticTeam]
        print(decodedTeams)

        
        defaultsChanged()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        
//        if let loadedCart = UserDefaults.standard.array(forKey: "favorites") as? [[String: Any]] {
//            print(loadedCart)  // [[price: 19.99, qty: 1, name: A], [price: 4.99, qty: 2, name: B]]"
//        }
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
        return resultArray
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
        return filteredTeamList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as? TeamCell
        cell?.backgroundColor = .clear
        
        if let teamPic = filteredTeamList?[indexPath.row].picture {
            cell?.teamLogoImageView.image = UIImage(named: teamPic)
        } else {
            cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
        }
        if let teamName = filteredTeamList?[indexPath.row].name {
            cell?.teamNameLabel.text = teamName
        }
        if UserDefaults.standard.bool(forKey: "isDarkMode") == true {
            cell?.teamNameLabel.textColor = .white
        } else {
            cell?.teamNameLabel.textColor = .black
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let row = indexPath.row
        var teamToFavorite: StaticTeam?
        teamToFavorite = filteredTeamList?[row]
        print("Favorite: \(teamToFavorite!)")
        let favorite = UITableViewRowAction(style: .default, title: "Favorite") { (action, indexPath) in
            print(self.favoritesTeamList ?? "Empty")
            self.favoritesTeamList?.append(teamToFavorite!)
            print(self.favoritesTeamList!)
            // save team to favorites
            //UserDefaults.standard.set(self.favoritesTeamList, forKey: "favorites")
            let encodedData: Data?
            encodedData = NSKeyedArchiver.archivedData(withRootObject: self.favoritesTeamList!)

            if encodedData == nil { return }
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: "favorites")
            self.getFavoriteAction()
        }
        favorite.backgroundColor = .orange
        return [favorite]
    }
    
    @objc func showFavorites() {
        // show only favorite teams in table view once star is clicked
    }
    
    func setupFavoriteBarButtonItem() {
        let favoriteItem = UIBarButtonItem(image: UIImage(named: "star_Icon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(showFavorites))
        navigationItem.leftBarButtonItem = favoriteItem
    }
    
    @objc func getFavoriteAction() {
//        let alert = UIAlertController(title: nil, message: "The \(teamToFavorite?.name ?? "") have been added to your favorites!", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
//            NSLog("The \"OK\" alert occured.")
//        }))
//        self.present(alert, animated: true, completion: nil)
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
