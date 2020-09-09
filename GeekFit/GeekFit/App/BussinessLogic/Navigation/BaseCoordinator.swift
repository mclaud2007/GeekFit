//
//  BaseCoordinator.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 06.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

class BaseCoordinator {
    var childCoordinators: [BaseCoordinator] = []
    
    func start() {
        // Переопределить в наследнике
    }
    
    func addDependency(_ coordinator: BaseCoordinator) {
        guard childCoordinators
                .contains(where: { element in element === coordinator }) == false
            else { return }
        
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: BaseCoordinator?) {
        guard childCoordinators.isEmpty == false,
            let coordinator = coordinator
            else { return }
        
        for (index, element) in childCoordinators.reversed().enumerated() where element === coordinator {
            childCoordinators.remove(at: index)
            break
        }
    }
    
    func setAsRoot(_ controller: UIViewController) {
        if #available(iOS 13, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = controller
        } else {
            UIApplication.shared.keyWindow?.rootViewController = controller
        }
    }
}
