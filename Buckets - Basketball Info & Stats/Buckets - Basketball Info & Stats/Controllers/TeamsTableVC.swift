//
//  TeamsTableVC.swift
//  Buckets - Basketball Info & Stats
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit

class TeamsTableVC: UITableViewController {
    var teamsData: [StaticTeam]?
    var teamToPass: StaticTeam?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTeams()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamsData?.count ?? 0
    }
    
    func parseTeamsFromJSONFile() -> [StaticTeam] {
        var resultArray = [StaticTeam]()
        guard let url = Bundle.main.url(forResource: "StaticTeams", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let JSON = try JSONSerialization.jsonObject(with: data, options: [])
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
        teamsData = parseTeamsFromJSONFile()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as? TeamCell
        cell?.selectionStyle = .none
        if let teamPic = teamsData?[indexPath.row].picture {
            cell?.teamLogo.image = UIImage(named: teamPic)
        } else {
            cell?.teamLogo.image = UIImage(named: "placeholder.png")
        }
        if let teamName = teamsData?[indexPath.row].name {
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
            teamToPass = teamsData?[(selectedIndexPath.row)]
            detailVC?.staticTeam = teamToPass
            let selectedCell = tableView.cellForRow(at: selectedIndexPath)
            detailVC?.detailImage = selectedCell?.imageView?.image
        }
    }
}
