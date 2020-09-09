//
//  ViewController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 30.08.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit
import GoogleMaps

@objc(MapViewController)
class MapViewController: UIViewController {
    // MARK: Outlet
    @IBOutlet weak var mapView: GMSMapView! {
        didSet {
            mapView.delegate = self
            mapView.isTrafficEnabled = true
            mapView.isMyLocationEnabled = true
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
    
    // Старт / стоп отслеживания
    @IBOutlet weak var btnStartDetection: UIButton! {
        didSet {
            btnStartDetection.backgroundColor = .systemBlue
        }
    }
    
    // КНопка отображеия текущего местоположения
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
    var onWorkoutList: (() -> Void)?
    var onWorkoutEnd: ((Double, Double) -> Void)?
    var onLogout: (() -> Void)?
    
    // Домашняя координата
    let coordinate = CLLocationCoordinate2D(latitude: 55.79622385766241, longitude: 37.53777835518122)
    
    // Сервисы
    var locationManager = LocationService.shared
    var workoutManager = WorkoutService()
    var trackerManager = TrackService()
    var currentWorkout: Workout?
        
    // Различные маркеры
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
        
        title = "Карта"
       
        // Делегат сервиса отслеживания положения
        locationManager.delegate = self
        
        // Попробуем посчитать количество записанных тренировок
        workoutCount = workoutManager.count()
        
        // Настриваем карту
        configureMap()
    }
    
    // Настройка карты
    private func configureMap() {
        let camera = GMSCameraPosition.init(target: coordinate, zoom: currentZoomLevel)
    
        mapView.camera = camera
        mapView.mapType = .hybrid
        
        // Трафик вкл / выкл
        btnTrafficOnOff.setImage(UIImage(systemName: (mapView.isTrafficEnabled == true ? "car.fill" : "car")),
                                 for: .normal
        )
    }
    
    // Настрока отображения пути
    private func configureRoutePath() {
        // Удалим старую линию с карты
        route?.map = nil
        routePath = nil
        
        // Создаем новый путь
        route = GMSPolyline()
        route?.map = mapView
        
        routePath = GMSMutablePath()
        
    }
    
    private func loadPathFromWorkoutWith(activityID: String) {
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
        
    func onWorkoutSelect(_ activityID: String) {
        loadPathFromWorkoutWith(activityID: activityID)
    }
    
    func onWorkoutDelete(_ activityID: String) {
        // Если удаляемая тренировка - текущая надо очистить и карту
        if currentWorkout?.activityID == activityID {
            configureRoutePath()
            currentWorkout = nil
        }
        
        // Удаляем тренировку и путь
        if workoutManager.removeWith(workoutID: activityID) {
            // Удаляем путь из тренировки
            trackerManager.removePathWith(workoutID: activityID)
            workoutCount -= 1
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
    
    @IBAction func btnExitClicked(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLogin")
        
        // Создаем окно с вопросом дейтсвительно ли пользователь желает выйти
        let actionVC = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.onLogout?()
        }
        
        let actionCancel = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        actionVC.addAction(actionOK)
        actionVC.addAction(actionCancel)
        
        present(actionVC, animated: true)
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
            var totalDistance: Double?
            
            if let lastLocation = locationManager.lastKnownLocation,
                let firstLocation = locationManager.firstKnownLocation {
                totalDistance = trackerManager.calculateDistanceFrom(first: firstLocation, second: lastLocation)
            }
            
            // Останавливаем тренировку
            workoutManager.stop(distance: totalDistance)
            
            // Останавливаем отслеживаение
            locationManager.stop()
            
        }
    }
    
    @IBAction func btnWorkoutListClicked(_ sender: Any) {
        guard workoutCount > 0 else {
            showErrorMessage(message: "Нет записанных тренировок.")
            return
        }
        
        guard locationManager.isUpdateLocationStarted == false else {
            showErrorMessage(message: "Тренировка запущена. Для просмотра списка её необходимо остановить.")
            return
        }
        
        // Переход к окну со списком тренировок
        onWorkoutList?()
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
        
        // открываем экран отчета о тренировке
        onWorkoutEnd?(currentWorkout?.timeTotal ?? 0, currentWorkout?.pathLenght ?? 0)
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

// MARK: GMSMApViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = "Долгота: \(location.latitude),\nширота: \(location.longitude)"
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 0.4
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
}
