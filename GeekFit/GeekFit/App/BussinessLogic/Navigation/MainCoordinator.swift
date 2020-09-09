//
//  MainCoordinator.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 06.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

final class MainCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var mapViewController: MapViewController?
    var onFinishFlow: (() -> Void)?
    
    override func start() {
        let controller = AppManager.shared.getScreenPage(identifier: MapViewController.self)
        let rootController = UINavigationController(rootViewController: controller)
        
        controller.onWorkoutList = { [weak self] in
            self?.showWorkoutListModule()            
        }
        
        controller.onLogout = { [weak self] in
            self?.onFinishFlow?()
        }
        
        controller.onWorkoutEnd = { [weak self] (time: Double, length: Double) in
            self?.showEndWorkoutModule(time: time, length: length)
        }
        
        self.rootController = rootController
        self.mapViewController = controller
        setAsRoot(rootController)
    }
    
    private func showWorkoutListModule() {
        let controller = AppManager.shared.getScreenPage(identifier: WorkoutListViewController.self)
        
        // Выбрали для отображения тренировку
        controller.didWorkoutSelect = { [weak self] activityID in
            self?.mapViewController?.onWorkoutSelect(activityID)
        }
        
        // Выбрали удаление тренировки
        controller.didWorkoutDelete = { [weak self] activityID in
            self?.mapViewController?.onWorkoutDelete(activityID)
        }
        
        self.rootController?.present(controller, animated: true)
        
    }
    
    private func showEndWorkoutModule(time: Double, length: Double) {
        let controller = AppManager.shared.getScreenPage(identifier: EndWorkoutViewController.self)
        
        controller.totalTime = time
        controller.totalLength = length
        
        self.rootController?.present(controller, animated: true)
    }
}
