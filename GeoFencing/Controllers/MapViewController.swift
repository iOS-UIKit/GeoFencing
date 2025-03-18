//
//  MapViewController.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    private let mapView = MKMapView()
    private let locationsViewModel = LocationsViewModel()
    private let remindersViewModel = RemindersViewModel()
    private let locationManager = CLLocationManager()
    private let showRemindersButton = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)
    private let locateUserButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var initialLocationSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        setupLocationManager()
        setupGeofenceManager()
        
        title = "GeoFence Reminders"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshMap()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.reuseIdentifier)
        view.addSubview(mapView)
        
        showRemindersButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        showRemindersButton.backgroundColor = .systemBackground
        showRemindersButton.tintColor = .systemBlue
        showRemindersButton.layer.cornerRadius = 25
        showRemindersButton.layer.shadowColor = UIColor.black.cgColor
        showRemindersButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        showRemindersButton.layer.shadowOpacity = 0.2
        showRemindersButton.layer.shadowRadius = 3
        showRemindersButton.addTarget(self, action: #selector(showRemindersButtonTapped), for: .touchUpInside)
        view.addSubview(showRemindersButton)
        
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.backgroundColor = .systemBackground
        refreshButton.tintColor = .systemBlue
        refreshButton.layer.cornerRadius = 25
        refreshButton.layer.shadowColor = UIColor.black.cgColor
        refreshButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        refreshButton.layer.shadowOpacity = 0.2
        refreshButton.layer.shadowRadius = 3
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        view.addSubview(refreshButton)
        
        locateUserButton.setImage(UIImage(systemName: "location"), for: .normal)
        locateUserButton.backgroundColor = .systemBackground
        locateUserButton.tintColor = .systemBlue
        locateUserButton.layer.cornerRadius = 25
        locateUserButton.layer.shadowColor = UIColor.black.cgColor
        locateUserButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        locateUserButton.layer.shadowOpacity = 0.2
        locateUserButton.layer.shadowRadius = 3
        locateUserButton.addTarget(self, action: #selector(locateUserButtonTapped), for: .touchUpInside)
        view.addSubview(locateUserButton)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemBlue
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        showRemindersButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        locateUserButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            showRemindersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            showRemindersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            showRemindersButton.widthAnchor.constraint(equalToConstant: 50),
            showRemindersButton.heightAnchor.constraint(equalToConstant: 50),
            
            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            refreshButton.bottomAnchor.constraint(equalTo: showRemindersButton.topAnchor, constant: -16),
            refreshButton.widthAnchor.constraint(equalToConstant: 50),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            
            locateUserButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            locateUserButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            locateUserButton.widthAnchor.constraint(equalToConstant: 50),
            locateUserButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        locationsViewModel.onLocationsUpdated = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.updateMapAnnotations()
        }
        
        locationsViewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.showAlert(with: "Error", message: errorMessage)
        }
        
        remindersViewModel.onRemindersUpdated = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.updateMapAnnotations()
        }
        
        remindersViewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.showAlert(with: "Error", message: errorMessage)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupGeofenceManager() {
        GeofenceManager.shared.delegate = self
    }
    
    private func refreshMap() {
        activityIndicator.startAnimating()
        locationsViewModel.fetchLocations()
        remindersViewModel.loadReminders()
    }
    
    private func updateMapAnnotations() {
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        mapView.removeOverlays(mapView.overlays)
        
        for i in 0..<locationsViewModel.numberOfLocations() {
            if let location = locationsViewModel.getLocation(at: i) {
                let hasReminder = remindersViewModel.getReminderForLocation(locationId: location.id) != nil
                let annotation = LocationAnnotation(location: location, isReminder: hasReminder)
                mapView.addAnnotation(annotation)
            }
        }
        
        for i in 0..<remindersViewModel.numberOfReminders() {
            if let reminder = remindersViewModel.getReminder(at: i), reminder.isActive {
                let coordinate = CLLocationCoordinate2D(latitude: reminder.latitude, longitude: reminder.longitude)
                let circle = MKCircle(center: coordinate, radius: reminder.radius)
                mapView.addOverlay(circle)
            }
        }
    }
    
    private func centerOnUserLocation() {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: userLocation,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
            mapView.setRegion(region, animated: true)
            
            locateUserButton.tintColor = .systemBlue
            locateUserButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.locateUserButton.setImage(UIImage(systemName: "location"), for: .normal)
            }
        } else {
            showAlert(with: "Location Unavailable", message: "Unable to determine your current location.")
        }
    }
    
    @objc private func showRemindersButtonTapped() {
        let reminderListVC = ReminderListViewController(remindersViewModel: remindersViewModel)
        reminderListVC.delegate = self
        let navController = UINavigationController(rootViewController: reminderListVC)
        present(navController, animated: true)
    }
    
    @objc private func refreshButtonTapped() {
        refreshMap()
    }
    
    @objc private func locateUserButtonTapped() {
        centerOnUserLocation()
    }
    
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLocationPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Access Required",
            message: "This app needs your location to monitor geofences. Please enable location access in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let locationAnnotation = annotation as? LocationAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.reuseIdentifier, for: annotation) as! CustomAnnotationView
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            circleRenderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.systemBlue
            circleRenderer.lineWidth = 1.0
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? LocationAnnotation else { return }
        
        let detailVC = ReminderDetailViewController(location: annotation.location, remindersViewModel: remindersViewModel)
        detailVC.delegate = self
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if !initialLocationSet {
                centerOnUserLocation()
                initialLocationSet = true
            }
        case .denied, .restricted:
            showLocationPermissionDeniedAlert()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("sameed - MapViewController - didUpdateLocations")
        guard !initialLocationSet, let location = locations.first else { return }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        mapView.setRegion(region, animated: true)
        initialLocationSet = true
        
        // locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: GeofenceManagerDelegate {
    func didEnterRegion(region: CLRegion) {
        if let circularRegion = region as? CLCircularRegion,
           let reminder = remindersViewModel.getReminderById(UUID(uuidString: region.identifier) ?? UUID()) {
            
            let title = "You've arrived at \(reminder.name)"
            let message = "You are now entering the area you set a reminder for."
            
            if UIApplication.shared.applicationState == .active {
                showAlert(with: title, message: message)
            }
            
            updateMapAnnotations()
        }
    }
    
    func didExitRegion(region: CLRegion) {
        if let circularRegion = region as? CLCircularRegion,
           let reminder = remindersViewModel.getReminderById(UUID(uuidString: region.identifier) ?? UUID()) {
            
            let title = "You've left \(reminder.name)"
            let message = "You are now exiting the area you set a reminder for."
            
            if UIApplication.shared.applicationState == .active {
                showAlert(with: title, message: message)
            }
            
            updateMapAnnotations()
        }
    }
    
    func didChangeAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("Location authorization changed to Always")
            remindersViewModel.loadReminders()
        case .authorizedWhenInUse:
            print("Location authorization changed to When In Use")
            let alert = UIAlertController(
                title: "Limited Location Access",
                message: "For background geofence notifications, please allow 'Always' access to location in Settings.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .denied, .restricted:
            print("Location authorization denied or restricted")
            showLocationPermissionDeniedAlert()
        default:
            break
        }
    }
}

extension MapViewController: ReminderListViewControllerDelegate {
    func didSelectReminder(_ reminder: GeoFenceReminder) {
        let coordinate = CLLocationCoordinate2D(latitude: reminder.latitude, longitude: reminder.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: reminder.radius * 4, longitudinalMeters: reminder.radius * 4)
        mapView.setRegion(region, animated: true)
        
        dismiss(animated: true, completion: nil)
    }
}

extension MapViewController: ReminderDetailViewControllerDelegate {
    func didSaveReminder(_ reminder: GeoFenceReminder) {
        updateMapAnnotations()
    }
} 
