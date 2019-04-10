//
//  SettingsTableViewController.swift
//  vcoin
//
//  Created by Marcin Czachurski on 18.01.2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - View loading

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Application version

    func getAppVersion() -> String {
        return "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
    }

    // MARK: - Theme style


    // MARK: - Actions

    

    @IBAction func doneAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.unselectSelectedRow()
//
//        if indexPath.section == 1 && indexPath.row == 1 {
//            "https://github.com/mczachurski/vcoin".openInBrowser()
//        } else if indexPath.section == 1 && indexPath.row == 2 {
//            "https://github.com/mczachurski/vcoin/issues".openInBrowser()
//        } else if indexPath.section == 1 && indexPath.row == 3 {
//            "https://twitter.com/mczachurski".openInBrowser()
//        }
//    }

    // MARK: - Navigation
}
