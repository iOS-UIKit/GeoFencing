//
//  CoreDataManager.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GeoFencing")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - GeoFence Reminder Operations
    
    func createGeoFenceReminder(locationId: String, name: String, latitude: Double, longitude: Double, radius: Double, category: String, note: String) -> GeoFenceReminder? {
        let context = persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "GeoFenceReminderEntity", in: context) else {
            return nil
        }
        
        let reminder = GeoFenceReminderEntity(entity: entity, insertInto: context)
        reminder.id = UUID()
        reminder.locationId = locationId
        reminder.name = name
        reminder.latitude = latitude
        reminder.longitude = longitude
        reminder.radius = radius
        reminder.category = category
        reminder.note = note
        reminder.isActive = true
        
        saveContext()
        return reminder.toModel()
    }
    
    func fetchAllGeoFenceReminders() -> [GeoFenceReminder] {
        let fetchRequest: NSFetchRequest<GeoFenceReminderEntity> = GeoFenceReminderEntity.fetchRequest()
        
        do {
            let reminders = try viewContext.fetch(fetchRequest)
            return reminders.map { $0.toModel() }
        } catch {
            print("Error fetching geofence reminders: \(error)")
            return []
        }
    }
    
    func updateGeoFenceReminder(id: UUID, isActive: Bool) -> Bool {
        let fetchRequest: NSFetchRequest<GeoFenceReminderEntity> = GeoFenceReminderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let reminders = try viewContext.fetch(fetchRequest)
            if let reminder = reminders.first {
                reminder.isActive = isActive
                saveContext()
                return true
            }
            return false
        } catch {
            print("Error updating geofence reminder: \(error)")
            return false
        }
    }
    
    func deleteGeoFenceReminder(id: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<GeoFenceReminderEntity> = GeoFenceReminderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let reminders = try viewContext.fetch(fetchRequest)
            if let reminder = reminders.first {
                viewContext.delete(reminder)
                saveContext()
                return true
            }
            return false
        } catch {
            print("Error deleting geofence reminder: \(error)")
            return false
        }
    }
}

// MARK: - Fetch Request Extension
extension GeoFenceReminderEntity {
    static func fetchRequest() -> NSFetchRequest<GeoFenceReminderEntity> {
        return NSFetchRequest<GeoFenceReminderEntity>(entityName: "GeoFenceReminderEntity")
    }
} 
