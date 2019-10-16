//
//  SettingsTableViewController.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import StoreKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var darkModeCell: UIView!
    @IBOutlet weak var contactUsCell: UITableViewCell!
    @IBOutlet weak var rateAppCell: UITableViewCell!
    @IBOutlet weak var followUsCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var darkModeSwitchOutlet: UISwitch!
    @IBOutlet weak var contactUsLabel: UILabel!
    @IBOutlet weak var rateAppLabel: UILabel!
    @IBOutlet weak var followUsLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultsChanged()
        darkModeSwitchOutlet.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
        navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.versionNumberLabel.text = getAppVersion()
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
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
        self.tableView.indicatorStyle = .white;
        self.darkModeCell.backgroundColor = .black
        self.rateAppCell.backgroundColor = .black
        self.contactUsCell.backgroundColor = .black
        self.followUsCell.backgroundColor = .black
        self.versionCell.backgroundColor = .black
        self.rateAppCell.setDisclosure(toColour: .white)
        self.contactUsCell.setDisclosure(toColour: .white)
        self.followUsCell.setDisclosure(toColour: .white)
        self.darkModeSwitchOutlet.backgroundColor = .black
        self.contactUsLabel.textColor = .white
        self.rateAppLabel.textColor = .white
        self.followUsLabel.textColor = .white
        self.versionLabel.textColor = .white
        self.versionNumberLabel.textColor = .white
        self.darkModeLabel.textColor = .white
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = hexStringToUIColor(hex: "#212121")
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        self.tableView.indicatorStyle = .default;
        self.darkModeCell.backgroundColor = .white
        self.contactUsCell.backgroundColor = .white
        self.rateAppCell.backgroundColor = .white
        self.followUsCell.backgroundColor = .white
        self.versionCell.backgroundColor = .white
        self.rateAppCell.setDisclosure(toColour: .black)
        self.contactUsCell.setDisclosure(toColour: .black)
        self.followUsCell.setDisclosure(toColour: .black)
        self.darkModeSwitchOutlet.backgroundColor = .white
        self.contactUsLabel.textColor = .black
        self.rateAppLabel.textColor = .black
        self.followUsLabel.textColor = .black
        self.versionLabel.textColor = .black
        self.versionNumberLabel.textColor = .black
        self.darkModeLabel.textColor = .black
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = hexStringToUIColor(hex: "#E9E9EB")
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    @IBAction func toggleDarkModeSwitch(_ sender: UISwitch) {
        var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            isDarkMode = false
            updateToLightTheme()
            UserDefaults.standard.set(false, forKey: "isDarkMode")
        } else {
            isDarkMode = true
            updateToDarkTheme()
            UserDefaults.standard.set(true, forKey: "isDarkMode")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.unselectSelectedRow()
        if indexPath.section == 1 && indexPath.row == 0 {
            let email = "realbucketsapp@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            SKStoreReviewController.requestReview()
        } else if indexPath.section == 1 && indexPath.row == 2 {
            let bucketsTwitterProfileUrl = "https://twitter.com/RealBucketsApp"
            let escapedShareString = bucketsTwitterProfileUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let url = URL(string: escapedShareString)
            if let url = URL(string: "\(url!)"), !url.absoluteString.isEmpty {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func getAppVersion() -> String {
        return "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
    }
}

extension UIColor {
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        UIColor.red.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a)
    }
}
