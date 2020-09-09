//
//  EndWorkoutViewController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 09.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

@objc(EndWorkoutViewController)
class EndWorkoutViewController: UIViewController {
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblTotalLenght: UILabel!
    
    var totalTime: Double?
    var totalLength: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Всего секунд, минут, часов
        let totalSeconds = Int(totalTime ?? 0)
        let totalMinutes = (totalSeconds%3600) / 60
        let totalHours = totalSeconds/3600

        // Do any additional setup after loading the view.
        lblTotalTime.text = "\(String(totalHours)) ч. \(String(totalMinutes)) м. \(String(totalSeconds)) с."
        lblTotalLenght.text = "\(String(Int(totalLength ?? 0))) метров"
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true)
    }    
}
