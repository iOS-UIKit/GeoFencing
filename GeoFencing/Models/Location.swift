//
//  Location.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import Foundation
import CoreLocation

struct Location: Codable, Identifiable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let category: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
} 
