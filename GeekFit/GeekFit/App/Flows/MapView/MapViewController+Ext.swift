//
//  MapViewController+Ext.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 06.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

// MARK: GMSMApViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = "Долгота: \(location.latitude),\nширота: \(location.longitude)"
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 0.4
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
}
