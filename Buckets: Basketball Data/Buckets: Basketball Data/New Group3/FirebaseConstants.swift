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
                self.remoteConfig.activate(completionHandler: nil)
            } else {
                print("Config not fetched")
            }
        }
    }
    
    func createDefaults() {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    func getImages() -> String{
        createDefaults()
        print("Config Value: \(self.remoteConfig["use_real_images"].stringValue!)")
        return self.remoteConfig["use_real_images"].stringValue!
    }
}
