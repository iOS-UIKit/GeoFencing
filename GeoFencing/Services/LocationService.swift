//
//  LocationService.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import Foundation

enum LocationServiceError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received from server"
        }
    }
}

protocol LocationServiceProtocol {
    func fetchLocations(completion: @escaping (Result<[Location], LocationServiceError>) -> Void)
}

class LocationService: LocationServiceProtocol {
    private let apiURL = "https://raw.githubusercontent.com/username/repo/main/mock_locations.json"
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetchLocations(completion: @escaping (Result<[Location], LocationServiceError>) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let locations = try decoder.decode([Location].self, from: data)
                completion(.success(locations))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func provideMockLocations() -> [Location] {
        return [
            Location(id: "1", name: "Apple Park", lat: 37.334722, lon: -122.008889, category: "Landmark"),
            Location(id: "2", name: "Homestead High School", lat: 37.341936, lon: -122.011394, category: "Education"),
            Location(id: "3", name: "Cupertino Middle School", lat: 37.345548, lon: -122.027970, category: "Education"),
            Location(id: "4", name: "Monta Vista High School", lat: 37.336567, lon: -122.001053, category: "Education"),
            Location(id: "5", name: "Cupertino Country Club", lat: 37.341258, lon: -121.995845, category: "Recreation"),
            Location(id: "6", name: "Whole Foods Market", lat: 37.322111, lon: -121.994631, category: "Shopping"),
            Location(id: "7", name: "Vallco Town Center", lat: 37.325700, lon: -122.000800, category: "Shopping"),
            Location(id: "8", name: "Cupertino Library", lat: 37.323267, lon: -122.004073, category: "Education"),
            Location(id: "9", name: "Kaiser Permanente", lat: 37.323069, lon: -121.998879, category: "Healthcare"),
            Location(id: "10", name: "Main Street Cupertino", lat: 37.323640, lon: -122.012658, category: "Landmark"),
            Location(id: "11", name: "De Anza College", lat: 37.319447, lon: -122.044870, category: "Education"),
            Location(id: "12", name: "Cupertino Memorial Park", lat: 37.319979, lon: -122.035945, category: "Park"),
            Location(id: "13", name: "Rancho San Antonio Park", lat: 37.319600, lon: -122.086200, category: "Park"),
            Location(id: "14", name: "Foothill Expressway", lat: 37.335100, lon: -122.067200, category: "Road"),
            Location(id: "15", name: "Stevens Creek County Park", lat: 37.342100, lon: -122.067800, category: "Park"),
            Location(id: "16", name: "HP Building", lat: 37.344521, lon: -122.040121, category: "Office"),
            Location(id: "17", name: "Infinite Loop", lat: 37.331800, lon: -122.028928, category: "Landmark"),
            Location(id: "18", name: "Starbucks Cupertino", lat: 37.325940, lon: -122.033012, category: "Cafe"),
            Location(id: "19", name: "Peet's Coffee", lat: 37.336710, lon: -122.030670, category: "Cafe"),
            Location(id: "20", name: "Philz Coffee", lat: 37.329365, lon: -121.982550, category: "Cafe"),
            Location(id: "21", name: "Apple Visitor Center", lat: 37.332600, lon: -122.007456, category: "Landmark"),
            Location(id: "22", name: "Tantau Park", lat: 37.337830, lon: -122.005824, category: "Park"),
            Location(id: "23", name: "Civic Center Plaza", lat: 37.323200, lon: -122.029700, category: "Landmark"),
            Location(id: "24", name: "Cupertino City Hall", lat: 37.323490, lon: -122.029870, category: "Government")
        ]
    }
} 
