//
//  Workout.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 05.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable unused_optional_binding

import Foundation
import RealmSwift

class WorkoutService: NSObject {
    private var realm = RealmService.shared
            
    func start() -> Workout? {
        let currentWorkout = Workout()
        try? realm.set(items: currentWorkout)
        
        return currentWorkout
    }
    
    func stop() {
        
    }
    
    func list() -> [Workout]? {
        guard let workouts = realm.get(Workout.self) else {
            return nil
        }
        
        return workouts.map { return $0 }
    }
    
    func count() -> Int {
        return list()?.count ?? 0
    }
    
    func removeWith(workoutID: String) -> Bool {
        guard let workout = realm.get(Workout.self)?.filter("activityID = '\(workoutID)'"), workout.isEmpty == false,
            let _ = try? realm.delete(items: workout) else {
                
            return false
        }
        
        return true
    }
    
    func loadWorkoutWith(workoutID: String) -> Workout? {
        guard let workoutFromDb = realm.get(Workout.self)?.filter("activityID = '\(workoutID)'"), workoutFromDb.isEmpty == false else {
            return nil
        }
        
        return workoutFromDb.first
    }
}
