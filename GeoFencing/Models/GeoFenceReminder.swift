//
//  GeoFenceReminder.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import Foundation
import CoreLocation

struct GeoFenceReminder: Identifiable {
    let id: UUID
    let locationId: String
    let name: String
    let latitude: Double
    let longitude: Double
    let radius: Double
    let category: String
    let note: String
    let isActive: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
} 
