//
//  PathsLog.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 03.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import RealmSwift

class Path: Object {
    @objc dynamic var pathID: String = UUID.init().uuidString
    @objc dynamic var latitude: Double
    @objc dynamic var longitude: Double
    @objc dynamic var timestamp: Date
    @objc dynamic var activityID: String
    
    override class func primaryKey() -> String? {
        return "pathID"
    }
    
    init(activityID: String, latitude: Double, longitude: Double) {
        self.activityID = activityID
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Date()
    }
    
    required init() {
        self.activityID = ""
        self.latitude = 0
        self.longitude = 0
        self.timestamp = Date()
    }
}
