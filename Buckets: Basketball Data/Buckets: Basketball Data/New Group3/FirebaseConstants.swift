//
//  FirebaseConstants.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/17/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FirebaseConstants: NSObject {
    
    var remoteConfig:RemoteConfig!
    
    func setupAPP() {
        createDefaults()
        remoteConfig.fetch(withExpirationDuration: 0) { (status, error) -> Void in
            if (status == RemoteConfigFetchStatus.success) {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
                
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
        }
    }
    
    func createDefaults() {
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    func getImages() -> String{
        createDefaults()
        return self.remoteConfig["use_real_images"].stringValue!
    }
}
