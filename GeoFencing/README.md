# GeoFencing Reminders App

An iOS app that allows users to set geofence-based reminders for points of interest.

## Features

- Fetch locations from an API
- Display locations on a map with custom annotations
- Set geofence reminders with custom radius selection
- Receive notifications when entering or exiting geofences
- Save and load reminders using Core Data
- View saved reminders on a map and in a list
- Toggle geofence monitoring
- Custom radius selector control

## Architecture

This app follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: Represent data structures and Core Data entities
- **Views**: User interface components including custom controls
- **ViewModels**: Handle business logic and provide data to views
- **Services**: Handle API requests, location monitoring, and data persistence

## Implementation Details

### API Integration
- Uses URLSession for network requests
- Handles errors and provides offline mode with mock data

### MapKit & Geofencing
- Displays custom annotations for locations
- Shows geofence radius overlays
- Uses CLLocationManager for geofence monitoring

### Core Data
- Persists geofence reminders
- Thread-safe operations with main context

### Custom Control
- RadiusSliderView for setting geofence radius with visual feedback

## Requirements

- iOS 14.0+
- Xcode 12.0+

## Setup Instructions

1. Clone the repository
2. Open GeoFencing.xcodeproj in Xcode
3. Update the locationService.apiURL value in LocationService.swift to point to your API endpoint
4. Build and run the app on a device or simulator

## Assumptions and Trade-offs

- For demo purposes, the app uses a mock API endpoint
- Location monitoring continues in the background
- Geofences are limited to 100m-1000m radius
- Maximum of 20 monitored regions (iOS system limitation)

## Future Improvements

- Add categories filtering for locations
- Implement search functionality
- Add custom notification sounds for different reminder types
- Optimize battery usage in background monitoring
- Add unit tests for Core Data and ViewModels

## License

This project is licensed under the MIT License - see the LICENSE file for details. 