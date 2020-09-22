//
//  ViewController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 30.08.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable redundant_discardable_let

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
    
    // Тип отображния карты
    private(set) var selectedMapType: OwnObservable<Int> = OwnObservable(1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Карта"
        
        // Попробуем посчитать количество записанных тренировок
        workoutCount = workoutManager.count()
        
        // Настриваем карту
        configureMap()
        
        // Настраиваем отслеживание изменение пути
        configureLocationChanged()
        
        // Настройка типа отображения карты
        configureMapTypeChanged()
        
        // Подписываемся на изменение состояния locationService
        configureLocationServiceStatus()
    }
    
    // Подписываемся на изменения segmentedControll
    private func configureMapTypeChanged() {
        selectedMapType.addObservers(self, options: [.new, .initial]) { [weak self] (value, _) in
            switch value {
            case 0:
                self?.mapView.mapType = .normal
            case 1:
                self?.mapView.mapType = .hybrid
            case 2:
                self?.mapView.mapType = .satellite
            case 3:
                self?.mapView.mapType = .terrain
            default:
                self?.mapView.mapType = .hybrid
            }
        }
    }
    
    // Подписываемся на изменения состояния работы локейшен сервиса
    private func configureLocationServiceStatus() {
        locationManager.isUpdateLocationStarted.addObservers(self, options: [.new]) { [weak self] (value, _) in
            guard let self = self else { return }
            
            if value == true {
                self.btnStartDetection.setTitle("Остановить отслеживание", for: .normal)
                self.btnStartDetection.backgroundColor = .systemGreen
                
                // обновим отрисовку пути
                self.configureRoutePath()
            } else if value == false {
                self.btnStartDetection.setTitle("Отслеживать", for: .normal)
                self.btnStartDetection.backgroundColor = .systemBlue
        
                // открываем экран отчета о тренировке
                self.onWorkoutEnd?(self.currentWorkout?.timeTotal ?? 0, self.currentWorkout?.pathLenght ?? 0)
            }
        }
    }
    
    // Настройка карты
    private func configureMap() {
        let camera = GMSCameraPosition.init(target: coordinate, zoom: currentZoomLevel)
    
        mapView.camera = camera
        mapView.mapType = .hybrid
        
        // Трафик вкл / выкл
        btnTrafficOnOff.setImage(UIImage(named: (mapView.isTrafficEnabled == true ? "car.fill" : "car")),
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
    
    // Настройка отслеживания обновления текущей позиции пользователя
    private func configureLocationChanged() {
        let _ = locationManager.currentObservableLoction.addObservers(self, options: [.new]) { [weak self] (coordinate, _) in
            guard let coordinate = coordinate else { return }
            
            // Перемещаем камеру в новую координату
            self?.mapView.animate(toLocation: coordinate)
            
            // Добавляем координаты в путь
            self?.routePath?.add(coordinate)
            self?.route?.path = self?.routePath
            
            // Сохраняем в рилм
            self?.trackerManager.track(workout: self?.currentWorkout, coordinate: coordinate)
        }
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
        selectedMapType.value = mapType.selectedSegmentIndex
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
        
        btnTrafficOnOff.setImage(UIImage(named: (mapView.isTrafficEnabled == true ? "car.fill" : "car")),
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
        
        if locationManager.isUpdateLocationStarted.value == false {
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
        
        guard locationManager.isUpdateLocationStarted.value == false else {
            showErrorMessage(message: "Тренировка запущена. Для просмотра списка её необходимо остановить.")
            return
        }
        
        // Переход к окну со списком тренировок
        onWorkoutList?()
    }
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
