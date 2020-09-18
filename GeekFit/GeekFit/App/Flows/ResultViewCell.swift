//
//  ResultViewCell.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 30.08.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit
import CoreLocation

class ResultViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
    
    func configureWith(place: CLPlacemark) {
        textLabel?.text = place.name
        detailTextLabel?.text = "\(place.country ?? "-") \(place.administrativeArea ?? "") \(place.postalCode ?? "-")"
    }
}
