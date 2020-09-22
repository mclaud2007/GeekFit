//
//  Notification.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 22.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

class Notification {
    private func makeContent(title: String, subtitle: String, body: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = 1
        
        return content
    }
    
    private func makeTrigger(interval: TimeInterval = 20) -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
    }
    
    func send(title: String, subtitle: String, content: String, interval: TimeInterval = 20) {
        let app = AppManager.shared
        print(app.isNotificationGranted)
        
        if app.isNotificationGranted {
            let message = makeContent(title: title, subtitle: subtitle, body: content)
            let trigger = makeTrigger(interval: interval)
            
            let request = UNNotificationRequest(identifier: "alarm",
                                                content: message,
                                                trigger: trigger
            )
            
            let center = AppManager.shared.center
            
            center.add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
