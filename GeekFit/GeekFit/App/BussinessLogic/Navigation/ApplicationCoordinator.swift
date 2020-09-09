//
//  ApplicationCoordinator.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 06.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

final class ApplicationCoordinator: BaseCoordinator {
    override func start() {
        // В зависимости от статуса
        if UserDefaults.standard.bool(forKey: "isLogin") {
            let coordinator = MainCoordinator()
            
            coordinator.onFinishFlow = { [weak self, weak coordinator] in
                self?.removeDependency(coordinator)
                self?.start()
            }
            
            addDependency(coordinator)
            coordinator.start()
            
        } else {
            let coordinator = LoginCoordinator()
            
            coordinator.onFinishFlow = { [weak self, weak coordinator] in
                self?.removeDependency(coordinator)
                self?.start()
            }
            
            addDependency(coordinator)
            coordinator.start()
        }        
    }
}
