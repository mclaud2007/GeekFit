//
//  AppManager.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 06.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.

import Foundation
import UIKit

final class AppManager {
    static let shared = AppManager()
    var coordinator: BaseCoordinator?
    
    enum StoryBoardName: String {
        case main = "Main"
        case users = "Users"
    }
    
    func start() {
        coordinator = ApplicationCoordinator()
        coordinator?.start()
    }
    
    func getStoryboardNameBy(class name: String) -> String? {
        let storyboardName: StoryBoardName?
        
        switch name {
        case "MapViewController", "WorkoutListViewController", "EndWorkoutViewController":
            storyboardName = .main
        case "LoginViewController", "RegisterViewController":
            storyboardName = .users
        default:
            storyboardName = nil
        }
        
        return storyboardName?.rawValue
    }
        
    func getScreenPage<T: UIViewController>(identifier: T.Type) -> T {
        let storyboardIdentifier = NSStringFromClass(T.self)
        let bundle = Bundle(for: T.self)
        
        guard let storyboardName = getStoryboardNameBy(class: storyboardIdentifier),
            let viewController = UIStoryboard(name: storyboardName, bundle: bundle)
                .instantiateViewController(withIdentifier: storyboardIdentifier) as? T else {
                    fatalError("View controller with identifier \(storyboardIdentifier) not found")
        }
        
        return viewController
    }
}
