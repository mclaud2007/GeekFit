//
//  RealmService.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 03.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmService {
    static var shared = RealmService()
    var realmDeleteMigration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    var realm: Realm?
    
    init() {
        realm = try? Realm(configuration: realmDeleteMigration)
    }

    func get<T: Object>(_ type: T.Type) -> Results<T>? {
        return realm?.objects(type) ?? nil
    }
    
    func set<T: Object>(items: T) throws {
        try realm?.write {
            realm?.add(items.self, update: Realm.UpdatePolicy.modified)
        }
    }
    
    func delete<T: Object>(items: T) throws {
        try realm?.write {
            realm?.delete(items)
        }
    }
        
    func delete<T: Object>(items: Results<T>) throws {
        try realm?.write {
            realm?.delete(items)
        }
    }
}
