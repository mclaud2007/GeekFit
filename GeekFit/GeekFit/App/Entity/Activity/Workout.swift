//
//  Log.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 03.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import RealmSwift

class Workout: Object {
    @objc dynamic var title: String
    @objc dynamic var activityID: String = UUID.init().uuidString
    @objc dynamic var pathLenght: Double
    @objc dynamic var timeTotal: Double
    @objc dynamic var timestamp: Date
    
    override class func primaryKey() -> String? {
        return "activityID"
    }
    
    init (title: String?) {
        self.title = title ?? "Тренировка"
        self.pathLenght = 0
        self.timeTotal = 0
        self.timestamp = Date()
    }
    
    required init() {
        self.title = "Тренировка"
        self.pathLenght = 0
        self.timeTotal = 0
        self.timestamp = Date()
    }
}
