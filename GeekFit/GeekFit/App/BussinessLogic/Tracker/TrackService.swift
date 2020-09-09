//
//  TrackService.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 05.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable weak_delegate

import Foundation
import CoreLocation
import GoogleMaps
import RealmSwift

protocol TrackServiceProto {
    func didUpdateTrackWith(error: Error)
}

final class TrackService: NSObject {
    var delegate: TrackServiceProto?
    let realm = RealmService.shared
    
    func track(workout: Workout?, coordinate: CLLocationCoordinate2D?) {
        guard let workout = workout, let coordinate = coordinate else { return }
        
        // Создаем объект типа путь
        let path = Path(activityID: workout.activityID,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude)
        
        // И пробуем его записать в базу
        do {
            try RealmService.shared.set(items: path)

        } catch let error {
            delegate?.didUpdateTrackWith(error: error)
        }
    }
    
    func listWith(workoutID: String) -> [Path]? {
        guard let trackList = realm.get(Path.self)?
                                  .filter("activityID == '\(workoutID)'")
                                  .sorted(byKeyPath: "timestamp", ascending: true) else {
            
            return nil
        }
        
        return trackList.map { $0 }
        
    }
    
    func removePathWith(workoutID: String) {
        if let trackList = realm.get(Path.self)?
                                  .filter("activityID == '\(workoutID)'") {
            try? realm.delete(items: trackList)
        }
    }
    
    func calculateDistanceFrom(first: CLLocationCoordinate2D, second: CLLocationCoordinate2D) -> Double {
        return Double(GMSGeometryDistance(first, second))
    }
}
