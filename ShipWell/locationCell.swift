//
//  locationCell.swift
//  ShipWell
//
//  Created by Matthew Foster on 17/9/18.
//  Copyright © 2018 MatthewFoster. All rights reserved.
//

import UIKit
import MapKit

class locationCell: UITableViewCell {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var LocationView: MKMapView!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  
    
}
