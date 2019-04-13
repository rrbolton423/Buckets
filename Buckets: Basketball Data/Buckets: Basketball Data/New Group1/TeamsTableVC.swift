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
    var isFavoriteSelected: Bool = false
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
        defaultsChanged()
        if (self.isFavoriteSelected == false) {
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon")
        } else {
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
            break
        case true:
            if let teamPic = self.store.favoriteTeams[indexPath.row].picture {
                cell?.teamLogoImageView.image = UIImage(named: teamPic)
            } else {
                cell?.teamLogoImageView.image = UIImage(named: "placeholder.png")
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
            favorite.backgroundColor = .orange
            delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                print(self.unfilteredFavoritesTeamList ?? "Empty")
                self.deleteData(item: self.teamToDelete!)
//                tableView.reloadData()
                self.getDeleteAction()
            }
            delete.backgroundColor = .red
            break
            
        case true:
            teamToFavorite = self.store.favoriteTeams[row]
            teamToDelete = self.store.favoriteTeams[row]
            favorite = UITableViewRowAction(style: .default, title: "Favorite") { (action, indexPath) in
                self.saveData(item: self.teamToFavorite!)
//                tableView.reloadData()
                self.getFavoriteAction()
            }
            favorite.backgroundColor = .orange
            delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                self.deleteData(item: self.store.favoriteTeams[indexPath.row])
                tableView.reloadData()
                self.getDeleteAction()
            }
            delete.backgroundColor = .red
            break
        }
        return [delete, favorite]
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
            navigationItem.rightBarButtonItem?.image = UIImage(named: "star_Icon")
        } else {
            setupTrashBarButtonItem()
            loadData()
            start()
            defaultsChanged()
            self.isFavoriteSelected = !isFavoriteSelected
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
        let alert = UIAlertController(title: nil, message: "The \(teamToFavorite?.name ?? "") is a favorite", preferredStyle: .alert)
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
        let alert = UIAlertController(title: nil, message: "The \(teamToDelete?.name ?? "") is not a favorite", preferredStyle: .alert)
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
        let alert = UIAlertController(title: nil, message: "All favorites have been deleted", preferredStyle: .alert)
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
