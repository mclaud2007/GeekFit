//
//  Users.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 08.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login: String
    @objc dynamic var password: String
    @objc dynamic var email: String
    @objc dynamic var name: String
    
    override class func primaryKey() -> String? {
        return "login"
    }
    
    init(login: String, password: String, email: String, name: String) {
        self.login = login
        self.password = password
        self.email = email
        self.name = name
    }
    
    required init() {
        self.login = ""
        self.password = ""
        self.email = ""
        self.name = ""
    }
}
