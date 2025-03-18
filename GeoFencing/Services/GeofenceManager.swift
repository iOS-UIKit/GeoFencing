import Foundation
import CoreLocation
import UserNotifications

protocol GeofenceManagerDelegate: AnyObject {
    func didEnterRegion(region: CLRegion)
    func didExitRegion(region: CLRegion)
    func didChangeAuthorizationStatus(status: CLAuthorizationStatus)
}

class GeofenceManager: NSObject {
    static let shared = GeofenceManager()
    
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    weak var delegate: GeofenceManagerDelegate?
    
    private override init() {
        super.init()
        setupLocationManager()
        setupNotifications()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    private func setupNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    func requestLocationAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func getCurrentAuthorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    func startMonitoring(reminder: GeoFenceReminder) {
        let region = createCircularRegion(from: reminder)
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(reminder: GeoFenceReminder) {
        let region = createCircularRegion(from: reminder)
        locationManager.stopMonitoring(for: region)
    }
    
    func isMonitoring(identifier: String) -> Bool {
        return locationManager.monitoredRegions.contains { $0.identifier == identifier }
    }
    
    // MARK: - Helper Methods
    
    private func createCircularRegion(from reminder: GeoFenceReminder) -> CLCircularRegion {
        let region = CLCircularRegion(
            center: reminder.coordinate,
            radius: reminder.radius,
            identifier: reminder.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension GeofenceManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.didChangeAuthorizationStatus(status: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.didEnterRegion(region: region)
        
        if let circularRegion = region as? CLCircularRegion {
            // Fetch reminder details from Core Data to get name for notification
            let reminders = CoreDataManager.shared.fetchAllGeoFenceReminders()
            if let reminder = reminders.first(where: { $0.id.uuidString == region.identifier }) {
                sendNotification(
                    title: "Reminder: \(reminder.name)",
                    body: "You've arrived at \(reminder.name)"
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.didExitRegion(region: region)
        
        if let circularRegion = region as? CLCircularRegion {
            // Fetch reminder details from Core Data to get name for notification
            let reminders = CoreDataManager.shared.fetchAllGeoFenceReminders()
            if let reminder = reminders.first(where: { $0.id.uuidString == region.identifier }) {
                sendNotification(
                    title: "Left Area: \(reminder.name)",
                    body: "You've left \(reminder.name)"
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region?.identifier ?? "unknown")")
        print("Error: \(error.localizedDescription)")
    }
} 