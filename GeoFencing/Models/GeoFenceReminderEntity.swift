//
//  GeoFenceReminderEntity.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import Foundation
import CoreData

@objc(GeoFenceReminderEntity)
public class GeoFenceReminderEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var locationId: String
    @NSManaged public var name: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var radius: Double
    @NSManaged public var category: String
    @NSManaged public var note: String
    @NSManaged public var isActive: Bool
    
    func toModel() -> GeoFenceReminder {
        return GeoFenceReminder(
            id: id,
            locationId: locationId,
            name: name,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            category: category,
            note: note,
            isActive: isActive
        )
    }
} 
