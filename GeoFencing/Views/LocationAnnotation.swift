//
//  LocationAnnotation.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import MapKit

class LocationAnnotation: MKPointAnnotation {
    let location: Location
    let isReminder: Bool
    
    init(location: Location, isReminder: Bool = false) {
        self.location = location
        self.isReminder = isReminder
        
        super.init()
        
        self.coordinate = location.coordinate
        self.title = location.name
        self.subtitle = location.category
    }
}

class CustomAnnotationView: MKMarkerAnnotationView {
    static let reuseIdentifier = "LocationAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        canShowCallout = true
        
        let button = UIButton(type: .detailDisclosure)
        rightCalloutAccessoryView = button
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let annotation = annotation as? LocationAnnotation else { return }
        
        switch annotation.location.category {
        case "Park":
            markerTintColor = .systemGreen
            glyphImage = UIImage(systemName: "leaf.fill")
        case "Cafe":
            markerTintColor = .systemBrown
            glyphImage = UIImage(systemName: "cup.and.saucer.fill")
        case "Museum":
            markerTintColor = .systemPurple
            glyphImage = UIImage(systemName: "building.columns.fill")
        case "Landmark":
            markerTintColor = .systemOrange
            glyphImage = UIImage(systemName: "building.2.fill")
        default:
            markerTintColor = .systemBlue
            glyphImage = UIImage(systemName: "mappin.circle.fill")
        }
        
        if annotation.isReminder {
            glyphTintColor = .white
            markerTintColor = .systemRed
        }
    }
} 
