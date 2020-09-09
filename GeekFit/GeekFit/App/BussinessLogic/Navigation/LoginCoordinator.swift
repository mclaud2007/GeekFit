//
//  AuthCoordinator.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 07.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

final class LoginCoordinator: BaseCoordinator {
    var onFinishFlow: (() -> Void)?
    var rootController: UINavigationController?
    
    override func start() {
        let controller = AppManager.shared.getScreenPage(identifier: LoginViewController.self)
            
        controller.onLogin = { [weak self] in
            self?.onFinishFlow?()
        }
        
        controller.onRegister = { [weak self] in
            self?.showRegisterModule()
        }
    
        let rootController = UINavigationController(rootViewController: controller)
        self.rootController = rootController
        
        setAsRoot(rootController)
    }
    
    private func showRegisterModule() {
        let controller = AppManager.shared.getScreenPage(identifier: RegisterViewController.self)
        
        controller.onRegistrationDone = { [weak self] in
            self?.onFinishFlow?()
        }
        
        rootController?.pushViewController(controller, animated: true)
    }
}
