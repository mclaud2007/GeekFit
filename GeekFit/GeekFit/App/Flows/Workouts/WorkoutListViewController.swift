//
//  WorkoutListViewController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 05.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

@objc(WorkoutListViewController)
class WorkoutListViewController: UIViewController {
    @IBOutlet weak var workoutTable: UITableView! {
        didSet {
            workoutTable.dataSource = self
            workoutTable.delegate = self
        }
    }
    
    var service = WorkoutService()
    var workouts: [Workout]? = []
    
    var didWorkoutSelect: ((String) -> Void)?
    var didWorkoutDelete: ((String) -> Void)?
    
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Список тренировок"

        workouts = service.list()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = .current
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension WorkoutListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let workout = workouts?[indexPath.row] {
            didWorkoutSelect?(workout.activityID)
        }
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let workout = workouts?[indexPath.row] {
                // Удаляем тренировку
                workouts?.remove(at: indexPath.row)
                workoutTable.reloadData()
                
                // Запускаем замыкание на удаление данных
                didWorkoutDelete?(workout.activityID)
                
            }
        }
    }
}

extension WorkoutListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = workoutTable.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
        
        if let workout = workouts?[indexPath.row] {
            cell.textLabel?.text = workout.title
            cell.detailTextLabel?.text = dateFormatter.string(from: workout.timestamp)
        }

        return cell
    }
}
