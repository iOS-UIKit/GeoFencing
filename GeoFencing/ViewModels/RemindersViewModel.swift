//
//  RemindersViewModel.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import Foundation
import CoreLocation

class RemindersViewModel {
    
    private let coreDataManager: CoreDataManager
    private let geofenceManager: GeofenceManager
    private var reminders: [GeoFenceReminder] = []
    
    var onRemindersUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared, 
         geofenceManager: GeofenceManager = GeofenceManager.shared) {
        self.coreDataManager = coreDataManager
        self.geofenceManager = geofenceManager
        loadReminders()
    }
    
    func loadReminders() {
        reminders = coreDataManager.fetchAllGeoFenceReminders()
        onRemindersUpdated?()
    }
    
    func createReminder(for location: Location, radius: Double, note: String) -> GeoFenceReminder? {
        guard let reminder = coreDataManager.createGeoFenceReminder(
            locationId: location.id,
            name: location.name,
            latitude: location.lat,
            longitude: location.lon,
            radius: radius,
            category: location.category,
            note: note
        ) else {
            onError?("Failed to create reminder")
            return nil
        }
        
        reminders.append(reminder)
        startMonitoring(reminder: reminder)
        onRemindersUpdated?()
        
        return reminder
    }
    
    func toggleReminder(with id: UUID, isActive: Bool) -> Bool {
        let result = coreDataManager.updateGeoFenceReminder(id: id, isActive: isActive)
        if result {
            if let index = reminders.firstIndex(where: { $0.id == id }) {
                let reminder = reminders[index]
                
                if isActive {
                    startMonitoring(reminder: reminder)
                } else {
                    stopMonitoring(reminder: reminder)
                }
                
                loadReminders()
            }
        } else {
            onError?("Failed to update reminder status")
        }
        
        return result
    }
    
    func deleteReminder(with id: UUID) -> Bool {
        if let reminder = reminders.first(where: { $0.id == id }) {
            stopMonitoring(reminder: reminder)
        }
        
        let result = coreDataManager.deleteGeoFenceReminder(id: id)
        if result {
            reminders.removeAll { $0.id == id }
            onRemindersUpdated?()
        } else {
            onError?("Failed to delete reminder")
        }
        
        return result
    }
    
    func getReminder(at index: Int) -> GeoFenceReminder? {
        guard index >= 0 && index < reminders.count else { return nil }
        return reminders[index]
    }
    
    func getReminderById(_ id: UUID) -> GeoFenceReminder? {
        return reminders.first { $0.id == id }
    }
    
    func getReminderForLocation(locationId: String) -> GeoFenceReminder? {
        return reminders.first { $0.locationId == locationId }
    }
    
    func numberOfReminders() -> Int {
        return reminders.count
    }
    
    private func startMonitoring(reminder: GeoFenceReminder) {
        geofenceManager.startMonitoring(reminder: reminder)
    }
    
    private func stopMonitoring(reminder: GeoFenceReminder) {
        geofenceManager.stopMonitoring(reminder: reminder)
    }
} 
