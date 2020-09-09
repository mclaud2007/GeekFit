//
//  Users.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 08.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable empty_count

import Foundation

enum RegisterError: Error {
    case userFound
    case registerError
}

final class UserService {
    static var shared = UserService()
    let realm = RealmService.shared
    
    func getUserWith(login: String, password: String) -> Bool {
        guard realm.get(User.self)?
            .filter("login = '\(login)' AND password = '\(password)'").count == 0 else {
                return true
        }
        
        return false
    }
    
    func register(user: User) throws {
        // Пытаемся найти пользователя по логину и паролю
        guard getUserWith(login: user.login, password: user.password) == false else {
                throw RegisterError.userFound
        }
        
        // Пытаемся записать данные
        do {
            try RealmService.shared.set(items: user)
        } catch {
            throw RegisterError.registerError
        }
    }
}
