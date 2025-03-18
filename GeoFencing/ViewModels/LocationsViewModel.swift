//
//  LocationsViewModel.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import Foundation

class LocationsViewModel {
    
    private let locationService: LocationServiceProtocol
    private var locations: [Location] = []
    
    var onLocationsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(locationService: LocationServiceProtocol = LocationService()) {
        self.locationService = locationService
    }
    
    func fetchLocations() {
        locationService.fetchLocations { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let locations):
                DispatchQueue.main.async {
                    self.locations = locations
                    self.onLocationsUpdated?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                    self.useMockLocations()
                }
            }
        }
    }
    
    func getLocation(at index: Int) -> Location? {
        guard index >= 0 && index < locations.count else { return nil }
        return locations[index]
    }
    
    func getLocationById(_ id: String) -> Location? {
        return locations.first { $0.id == id }
    }
    
    func numberOfLocations() -> Int {
        return locations.count
    }
    
    private func useMockLocations() {
        let mockLocations = locationService as? LocationService
        self.locations = mockLocations?.provideMockLocations() ?? []
        self.onLocationsUpdated?()
    }
} 
