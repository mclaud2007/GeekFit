//
//  ViewController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 30.08.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class MapViewController: UIViewController {
    // MARK: Outlet
    @IBOutlet weak var mapView: GMSMapView! {
        didSet {
            mapView.delegate = self
            mapView.isTrafficEnabled = true
            mapView.isMyLocationEnabled = true
            mapView.settings.compassButton = true
        }
    }
    
    // Выбор типа отображения карты
    @IBOutlet weak var mapType: UISegmentedControl! {
        didSet {
            mapType.selectedSegmentIndex = 1
        }
    }
    
    // Кнопка уменьшения карты
    @IBOutlet weak var zoomIn: UIButton! {
        didSet {
            zoomIn.layer.cornerRadius = 5
            zoomIn.layer.opacity = 0.8
            zoomIn.layer.borderColor = UIColor.darkGray.cgColor
            zoomIn.layer.borderWidth = 1
        }
    }
    
    // Кнопка увеличения карты
    @IBOutlet weak var zoomOut: UIButton! {
        didSet {
            zoomOut.layer.cornerRadius = 5
            zoomOut.layer.opacity = 0.8
            zoomOut.layer.borderColor = UIColor.darkGray.cgColor
            zoomOut.layer.borderWidth = 1
        }
    }
    
    // Вкл / выкл отображения трафика
    @IBOutlet weak var btnTrafficOnOff: UIButton! {
        didSet {
            btnTrafficOnOff.layer.cornerRadius = 5
            btnTrafficOnOff.layer.opacity = 0.8
            btnTrafficOnOff.layer.borderColor = UIColor.darkGray.cgColor
            btnTrafficOnOff.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var btnStartDetection: UIButton!
    
    @IBOutlet weak var btnMyCurrentLocation: UIButton! {
        didSet {
            btnMyCurrentLocation.layer.cornerRadius = 5
            btnMyCurrentLocation.layer.opacity = 0.8
            btnMyCurrentLocation.layer.borderColor = UIColor.darkGray.cgColor
            btnMyCurrentLocation.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var btnWorkoutList: UIButton!
    
    // MARK: Properties
    // Домашняя координата
    let coordinate = CLLocationCoordinate2D(latitude: 55.79622385766241, longitude: 37.53777835518122)
    
    // Сервисы
    var locationManager = LocationService.shared
    var workoutManager = WorkoutService()
    var trackerManager = TrackService()
    var currentWorkout: Workout?
        
    // Различные маркеры
    var marker: GMSMarker?
    let infoMarker = GMSMarker()
    
    //  Текущий уровень зума на карте
    var currentZoomLevel: Float = 17
    
    // Шаг для увеличения зума
    let zoomLevelStep: Float = 1
        
    // Путь на карте
    var route: GMSPolyline? {
        didSet {
            route?.strokeColor = .systemRed
            route?.strokeWidth = 5
        }
    }
    
    var routePath: GMSMutablePath?
        
    // Количество записанных тренировок
    var workoutCount: Int = 0 {
        didSet {
            btnWorkoutList.backgroundColor = workoutCount > 0 ? .systemBlue : .lightGray
            btnWorkoutList.tintColor = workoutCount > 0 ? .white : .black
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Делегат сервиса отслеживания положения
        locationManager.delegate = self
        
        // Попробуем посчитать количество записанных тренировок
        workoutCount = workoutManager.count()
        
        // Настриваем карту
        configureMap()
    }
    
    // Настройка карты
    func configureMap() {
        let camera = GMSCameraPosition.init(target: coordinate, zoom: currentZoomLevel)
    
        mapView.camera = camera
        mapView.mapType = .hybrid
        
        // Трафик вкл / выкл
        btnTrafficOnOff.setImage(UIImage(systemName: (mapView.isTrafficEnabled == true ? "car.fill" : "car")),
                                 for: .normal
        )
    }
    
    // Настрока отображения пути
    func configureRoutePath() {
        // Удалим старую линию с карты
        route?.map = nil
        routePath = nil
        
        // Создаем новый путь
        route = GMSPolyline()
        route?.map = mapView
        
        routePath = GMSMutablePath()
        
    }
    
    func loadPathFromWorkoutWith(activityID: String) {
        guard let paths = trackerManager.listWith(workoutID: activityID), !paths.isEmpty else { return }
        guard let firstCoordinate = paths.first else { return }
        
        // Загружаем тренировку
        currentWorkout = workoutManager.loadWorkoutWith(workoutID: activityID)
        
        // Передвинем камеру к первой координате
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: firstCoordinate.latitude,
                                                           longitude: firstCoordinate.longitude)
        )
        
        // Обновим путь
        configureRoutePath()
                
        // Нарисуем весь путь
        paths.forEach { path in
            routePath?.add(CLLocationCoordinate2D(latitude: path.latitude, longitude: path.longitude))
            route?.path = routePath
        }
    }

    @IBAction func goHome(_ sender: Any) {
        mapView.animate(toLocation: coordinate)
    }
    
    @IBAction func mapTypeChanged(_ sender: Any) {
        if let segmented = sender as? UISegmentedControl {
            switch segmented.selectedSegmentIndex {
            case 0:
                mapView.mapType = .normal
            case 1:
                mapView.mapType = .hybrid
            case 2:
                mapView.mapType = .satellite
            case 3:
                mapView.mapType = .terrain
            default:
                mapView.mapType = .hybrid
            }
        }
    }
    
    @IBAction func zoomInClicked(_ sender: Any) {
        if mapView.maxZoom >= (currentZoomLevel + zoomLevelStep) {
            currentZoomLevel += zoomLevelStep
        } else {
            currentZoomLevel = mapView.maxZoom
        }
        
        mapView.animate(toZoom: currentZoomLevel)
    }
    
    @IBAction func zoomOutClicked(_ sender: Any) {
        if mapView.minZoom <= (currentZoomLevel - zoomLevelStep) {
            currentZoomLevel -= zoomLevelStep
        } else {
            currentZoomLevel = mapView.minZoom
        }
        
        mapView.animate(toZoom: currentZoomLevel)
    }
    
    @IBAction func trafficOnOffClicked(_ sender: Any) {
        mapView.isTrafficEnabled = !mapView.isTrafficEnabled
        btnTrafficOnOff.setImage(UIImage(systemName: (mapView.isTrafficEnabled == true ? "car.fill" : "car")),
                                 for: .normal
        )        

    }
    
    @IBAction func btnAddMarkerClicked(_ sender: Any) {
        if marker == nil {
            marker = GMSMarker(position: coordinate)
            marker?.title = "Test"
            marker?.snippet = "Some description"
            marker?.map = mapView
            marker?.icon = GMSMarker.markerImage(with: .green)
            mapView.animate(toLocation: coordinate)
            
        } else {
            marker?.map = nil
            marker = nil
        }
    }
    
    @IBAction func btnMyCurrentLocationClicked(_ sender: Any) {
        guard locationManager.isUpdateLocationRestricted == false else {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            return
        }
        
        locationManager.currentLocation()
    }
    
    @IBAction func btnStartDetectionClicked(_ sender: Any) {
        // Проверяем включена ли поддержка отслеживания местоположения
        guard locationManager.isUpdateLocationRestricted == false else {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            return
        }
        
        if locationManager.isUpdateLocationStarted == false {
            // Стартуем новую тренировку
            currentWorkout = workoutManager.start()
            
            // Стартуем отслеживание координат
            locationManager.start()
                
            // Обновляем число тренировок
            workoutCount += 1
            
        } else {
            locationManager.stop()
            
        }
    }
    
    @IBAction func btnWorkoutListClicked(_ sender: Any) {
        guard workoutCount > 0 else {
            showErrorMessage(message: "Нет записанных тренировок.")
            return
        }
        
        // Инициализируем окно со списком тренировок
        guard let destination = AppManager.shared
                                          .getScreenPage(storyboard: "Main", identifier: "workoutListController")
                                                as? WorkoutListViewController else {
            return
        }
        
        // Загрузка выбранной тренировки
        destination.didWorkoutSelect = { [weak self] activityID in
            self?.loadPathFromWorkoutWith(activityID: activityID)
        }
        
        // Удаление выбранной тренировки
        destination.didWorkoutDelete = { [weak self] activityID in
            guard let self = self else { return }
            
            // Если удаляемая тренировка - текущая надо очистить и карту
            if self.currentWorkout?.activityID == activityID {
                self.configureRoutePath()
                self.currentWorkout = nil
            }
            
            // Удаляем тренировку и путь
            if self.workoutManager.removeWith(workoutID: activityID) {
                // Удаляем путь из тренировки
                self.trackerManager.removePathWith(workoutID: activityID)
                self.workoutCount -= 1
            }
        }
        
        navigationController?.present(destination, animated: true)        
    }
}

// MARK: BackgroundServiceProto
extension MapViewController: LocationServiceProto {
    func willUpdateLocationStarted() {
        btnStartDetection.setTitle("Остановить отслеживание", for: .normal)
        btnStartDetection.backgroundColor = .systemGreen
        
        // обновим отрисовку пути
        configureRoutePath()
    }
    
    func willUpdateLocationStopped() {
        btnStartDetection.setTitle("Отслеживать", for: .normal)
        btnStartDetection.backgroundColor = .systemBlue
    }
    
    func didLocationChanged(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else { return }
        
        // Перемещаем камеру в новую координату
        mapView.animate(toLocation: coordinate)
              
        // Добавляем координаты в путь
        routePath?.add(coordinate)
        route?.path = routePath
        
        // Сохраняем в рилм
        trackerManager.track(workout: currentWorkout, coordinate: coordinate)
    }
    
    func didUpdateIsInactive(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?) { }
}
