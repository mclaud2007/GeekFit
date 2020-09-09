//
//  BackgroundWork.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 05.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable weak_delegate

import Foundation
import UIKit
import CoreLocation

protocol LocationServiceProto {
    func willUpdateLocationStarted()
    func willUpdateLocationStopped()
    func didLocationChanged(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?)
    func didUpdateIsInactive(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?)
}

final class LocationService: NSObject {
    static let shared = LocationService()
    private(set) var locationManager: CLLocationManager?
    
    // Делегат сервиса
    var delegate: LocationServiceProto?
    
    // Заприщена ли проверка обновлений локации
    var isUpdateLocationRestricted: Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                return false
            default:
                return true
            }
        }
        
        return true
    }
    
    // Запущено ли отслеживание координат
    private(set) var isUpdateLocationStarted: Bool = false
    
    // Последняя известная нам координата
    private(set) var lastKnownLocation: CLLocationCoordinate2D?
    
    // Первая извесная нам координата - для расчета расстояния
    private(set) var firstKnownLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        
        // Если нам в принципе доступен локешен сервис - запросим права
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.requestAlwaysAuthorization()
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.pausesLocationUpdatesAutomatically = false
            locationManager?.delegate = self
        }
    }
    
    // Запуск обновления позиции
    func start() {
        firstKnownLocation = nil
        lastKnownLocation = nil
        
        isUpdateLocationStarted = true
        locationManager?.startUpdatingLocation()
        delegate?.willUpdateLocationStarted()
    }
    
    // Остановка обновления позиции
    func stop() {
        firstKnownLocation = nil
        lastKnownLocation = nil
        
        isUpdateLocationStarted = false
        locationManager?.stopUpdatingLocation()
        delegate?.willUpdateLocationStopped()
    }
    
    // Проверим фоновую активность
    func stillActive(coordinate: CLLocationCoordinate2D?) {
        // Координата не поменялась swiftlint:disable control_statement
        if (coordinate?.longitude == lastKnownLocation?.longitude && coordinate?.latitude == lastKnownLocation?.latitude) {
            // TODO: Добавить таймер для отслеживания того не забыл ли пользователь отключить тренировку
        }
        
        // Сохраним последнее известное положение
        lastKnownLocation = coordinate
        
        // Если нет координаты - значит она будет первой
        if firstKnownLocation == nil {
            firstKnownLocation = coordinate
        }
    }
    
    // Получаем текущую позицию
    func currentLocation() {
        locationManager?.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Проверим активность, в случае необходимости напомним пользователю об отключении тренировки
        stillActive(coordinate: locations.last?.coordinate)
        
        // Дернем делегат на тему новой координаты
        delegate?.didLocationChanged(manager, coordinate: locations.last?.coordinate)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
