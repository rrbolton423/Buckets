//
//  SettingsTableViewController.swift
//  vcoin
//
//  Created by Marcin Czachurski on 18.01.2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import UIKit
import StoreKit

class SettingsTableViewController: UITableViewController {

    // MARK: - View loading

    @IBOutlet weak var darkModeCell: UIView!
    @IBOutlet weak var rateAppCell: UITableViewCell!
    @IBOutlet weak var contactUsCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var darkModeSwitchOutlet: UISwitch!
    //var isDarkMode: Bool = false

    @IBOutlet weak var rateAppLabel: UILabel!
    @IBOutlet weak var contactUsLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    // MARK: - View loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.versionNumberLabel.text = getAppVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultsChanged()
        darkModeSwitchOutlet.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }

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
        navigationController?.navigationBar.barStyle = .black
        self.tableView.indicatorStyle = .white;

        self.darkModeCell.backgroundColor = .black
        self.rateAppCell.backgroundColor = .black
        self.contactUsCell.backgroundColor = .black
        self.versionCell.backgroundColor = .black
        self.darkModeSwitchOutlet.backgroundColor = .black
        
        self.rateAppLabel.textColor = .white
        self.contactUsLabel.textColor = .white
        self.versionLabel.textColor = .white
        self.versionNumberLabel.textColor = .white
        self.darkModeLabel.textColor = .white
        
        
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = hexStringToUIColor(hex: "#252525")
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        navigationController?.navigationBar.barStyle = .default
        self.tableView.indicatorStyle = .default;
        self.darkModeCell.backgroundColor = .white
        self.rateAppCell.backgroundColor = .white
        self.contactUsCell.backgroundColor = .white
        self.versionCell.backgroundColor = .white
        self.darkModeSwitchOutlet.backgroundColor = .white
        
        self.rateAppLabel.textColor = .black
        self.contactUsLabel.textColor = .black
        self.versionLabel.textColor = .black
        self.versionNumberLabel.textColor = .black
        self.darkModeLabel.textColor = .black
        
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Application version

    func getAppVersion() -> String {
        return "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
    }
    
    // MARK: - Actions
    
    @IBAction func toggleDarkModeSwitch(_ sender: UISwitch) {
        var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            isDarkMode = false
            print(isDarkMode)
            updateToLightTheme()
            UserDefaults.standard.set(false, forKey: "isDarkMode")  // Set the state

        }
        else {
            isDarkMode = true
            print(isDarkMode)
            updateToDarkTheme()
            UserDefaults.standard.set(true, forKey: "isDarkMode")  // Set the state
        }

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.unselectSelectedRow()
        
        if indexPath.section == 1 && indexPath.row == 0 {
            SKStoreReviewController.requestReview()
        } else if indexPath.section == 1 && indexPath.row == 1 {
            let email = "bolton.romell423@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

extension UIColor {
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        UIColor.red.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a) // Assuming you want the same alpha value.
    }
}
