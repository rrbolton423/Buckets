//
//  TodaysGamesCell.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/24/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import UIKit

class TodaysGamesCell: UITableViewCell {
    @IBOutlet weak var homeAfbeelding: UIImageView!
    @IBOutlet weak var homeTeamName: UILabel!
    @IBOutlet weak var awayAfbeelding: UIImageView!
    @IBOutlet weak var awayTeamName: UILabel!
    @IBOutlet weak var puckDrop: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var awayScore: UILabel!
    @IBOutlet weak var homeScore: UILabel!
    @IBOutlet weak var noGames: UILabel!
}
