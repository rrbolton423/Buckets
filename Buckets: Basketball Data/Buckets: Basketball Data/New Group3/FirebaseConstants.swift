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
    
    func setupAPP()
    {
        //Create Firebase defaults and make them accessible to the class
        createDefaults()
        
        //Fetch remote config values from Firebase
        remoteConfig.fetch(withExpirationDuration: 0) { (status, error) -> Void in
            if (status == RemoteConfigFetchStatus.success) {
                //print("Config fetched!")
                self.remoteConfig.activateFetched()
                
            } else {
                //print("Config not fetched")
                //print("Error \(error!.localizedDescription)")
            }
        }
    }
    
    func createDefaults()
    {
        //Instantiate the variable remoteConfig as an instance of Firebase remoteConfig
        remoteConfig = RemoteConfig.remoteConfig()
        
        //Enable developer mode. This ensure that the client side throttle is never reached and will allow data to be refreshed during development. Make sure this is set to false for production.
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        
        //Instantiate config settings of the remote config variable
        remoteConfig.configSettings = remoteConfigSettings
        
        //Point remote config to the plist containing the default values
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    func getImages()-> String
    {
        //Instantiate Firebase Defaults
        createDefaults()
        
        //Return button Text Default Value
        return self.remoteConfig["use_real_images"].stringValue!
    }
}
