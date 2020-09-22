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
    var center = UNUserNotificationCenter.current()
    
    var blurView: UIView? {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        if let rootViewController = rootViewController {
            blurView.frame = rootViewController.view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.tag = 1001
            
            return blurView
        } else {
            return nil
        }
    }
    
    // Ссылка на основной экран
    var rootViewController: UIViewController? {
        return coordinator?.getRootViewController()
    }
    
    // Показан ли эфект
    var isBlurEffectWasShown: Bool {
        guard let rootViewController = rootViewController,
            rootViewController.view.viewWithTag(1001) != nil else {
                return false
        }
        
        return true
    }
    
    // Получено ли разрешение на нотификацию
    var isNotificationGranted: Bool = false
    
    enum StoryBoardName: String {
        case main = "Main"
        case users = "Users"
    }
    
    init() {
        // Запрашиваем разрешение на отправку сообщений
        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            switch settings.authorizationStatus {
            case .authorized, .ephemeral, .provisional:
                self.isNotificationGranted = true
                
            default:
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, _) in
                    guard let self = self else { return }
                    self.isNotificationGranted = granted
                }
            }
        }
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
                            
        guard let storyboardName = getStoryboardNameBy(class: storyboardIdentifier),
            let viewController = UIStoryboard(name: storyboardName, bundle: nil)
                .instantiateViewController(withIdentifier: storyboardIdentifier) as? T else {
                    fatalError("View controller with identifier \(storyboardIdentifier) not found")
        }
        
        return viewController
    }
    
    func didShowBlurWhenInnactive() {
        if let rootViewController = rootViewController, let blurView = blurView {
            if isBlurEffectWasShown == false {
                rootViewController.view.addSubview(blurView)
            }
            
        }
    }
    
    func didHideBlurWhenActive() {
        if isBlurEffectWasShown, let viewWithTag = rootViewController?.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
    }
}
