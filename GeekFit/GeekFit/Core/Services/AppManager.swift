//
//  AppManager.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 06.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

final class AppManager {
    static let shared = AppManager()
    
    func getScreenPage(storyboard name: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(identifier: identifier)
    }
}
