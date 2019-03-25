//
//  StandingsCells.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/24/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import UIKit

class StandingsCell: UITableViewCell {
    
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var gamesPlayed: UILabel!
    @IBOutlet weak var wins: UILabel!
    @IBOutlet weak var losses: UILabel!
    @IBOutlet weak var winPercentage: UILabel!
}
