//
//  TodaysGamesTableVC.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import UserNotifications

class TodaysGamesTableVC: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGamesimage: UIImageView!
    @IBOutlet weak var noGames: UILabel!
    
    var gameTimer: Timer!
    
    //local file, for testing or when no games are being played or will be played today
//    var todaysGamesURL: URL = URL(string: "http://student.howest.be/brent.le.comte/20172018/native/shedule.json")!
    
    //live API
    var todaysGamesURL: URL = URL(string: "https://statsapi.web.nhl.com/api/v1/schedule")!
    var liveFeed = ""
    
    
//    var gameData: [Game] = []
//    let activityIndicator = UIActivityIndicatorView(style: .gray)
//
//    func addNavBarImage () {
//        let navController = navigationController!
//
//        let image = #imageLiteral(resourceName: "nhlLogo")
//        let imageView = UIImageView(image: image)
//
//        let bannerWidth = navController.navigationBar.frame.size.width
//        let bannerHeight = navController.navigationBar.frame.size.height
//
//        let bannerX = bannerWidth/2 - image.size.width/2
//        let bannerY = bannerHeight/2 - image.size.height/2
//
//        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
//        imageView.contentMode = .scaleAspectFit
//
//        navigationItem.titleView = imageView
//
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInfoBarButtonItem()
        //addNavBarImage()
        //loadTodaysGames()
    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//    func loadTodaysGames(){
//        print("load Games")
//
//        view.addSubview(activityIndicator)
//        activityIndicator.frame = view.bounds
//        activityIndicator.startAnimating()
//
//        let todaysGamesDatatask = URLSession.shared.dataTask(with: todaysGamesURL, completionHandler: dataLoaded)
//
//        todaysGamesDatatask.resume()
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 211
//    }
//
//    func dataLoaded(data:Data?,response:URLResponse?,error:Error?){
//        if let detailData = data{
//            let decoder = JSONDecoder()
//            do {
//                let jsondata = try decoder.decode(Initial.self, from: detailData)
//                if (jsondata.dates?.count)! > 0 {
//                gameData = jsondata.dates![0].games
//                DispatchQueue.main.async{
//
//                    self.noGames.isHidden = true
//                    self.noGamesimage.isHidden = true
//                    self.tableView.reloadData()
//                    self.activityIndicator.removeFromSuperview()
//                }
//                } else {
//                    DispatchQueue.main.async{
//                        self.tableView.isHidden = true
//                        self.noGames.isHidden = false
//                        self.noGamesimage.isHidden = false
//                        self.activityIndicator.removeFromSuperview()
//                    }
//                }
//            }catch let error{
//               print(error)
//            }
//        }else{
//            print(error!)
//        }
//    }
    
    
//
    
    func setupInfoBarButtonItem() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    @objc func getInfoAction() {
        let alert = UIAlertController(title: "Version 1.0", message: "This app is not endorsed by or affiliated with the National Basketball Association. Any trademarks used in the app are done so under “fair use” with the sole purpose of identifying the respective entities, and remain the property of their respective owners.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return gameData.count
        return 0

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todaysGamesCell", for: indexPath) as! TodaysGamesCell
//        let date = gameData[indexPath.row].gameDate;
//
//        let start = date.index(date.startIndex, offsetBy: 11)
//        let end = date.index(date.endIndex, offsetBy: -4)
//        let range = start..<end
//        liveFeed = gameData[indexPath.row].link
//
//        cell.homeTeamName.text = gameData[indexPath.row].teams.home.team?.name
//        cell.awayTeamName.text = gameData[indexPath.row].teams.away.team?.name
//        cell.homeAfbeelding.image = UIImage(named: (gameData[indexPath.row].teams.home.team?.name)!)
//        cell.awayAfbeelding.image = UIImage(named: (gameData[indexPath.row].teams.away.team?.name)!)
//        cell.puckDrop.text = String(date[range])
//        cell.venue.text = "@" + gameData[indexPath.row].venue.name

        return cell
    }
}
