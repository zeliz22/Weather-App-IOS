//
//  WeatherLocationManager.swift
//  zeliz22-FinalProject
//
//  Created by zaza elizbarashvili on 06/12/1403 AP.
//

import Foundation
import UIKit
import CoreLocation

class WeatherLocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    weak var viewController: WeatherViewControllerDelegate?
    
    // MARK: - Initialization
    init(viewController: WeatherViewControllerDelegate) {
        self.viewController = viewController
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted.")
            locationManager.startUpdatingLocation() // Start updates if authorized
        case .denied, .restricted:
            viewController?.showErrorPage(message: "Location access denied or restricted. Weather for your current location won't be displayed")
        case .notDetermined:
            print("Location access not determined.")
            locationManager.requestWhenInUseAuthorization() // Request permission
        @unknown default:
            viewController?.showErrorPage(message: "Unknown location authorization status.")
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation() // Start updates if authorized
            case .denied, .restricted:
                self.viewController?.showErrorPage(message: "Location access denied or restricted. Weather for your current location won't be displayed")
            case .notDetermined:
                break // Do nothing, wait for user response
            @unknown default:
                self.viewController?.showErrorPage(message: "Unknown location authorization status.")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Fetch weather for the current location
        viewController?.fetchWeatherForCurrentLocation(latitude: location.coordinate.latitude,
                                     longitude: location.coordinate.longitude)
        
        // Get the city name from the location
        getCityNameFromLocation(location) { cityName in
            DispatchQueue.main.async {
                if let cityName = cityName {
                    self.viewController?.currentLocationCityName = cityName // Store the city name
                    self.viewController?.fetchWeather(for: cityName) // Fetch weather for the city
                    self.viewController?.collectionView.reloadData() // Reload the collection view
                } else {
                    // Show error page if city name is nil
                    self.viewController?.showErrorPage(message: "Unable to determine your location. Please try again.")
                }
            }
        }
        
        locationManager.stopUpdatingLocation() // Stop updates after getting the location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                self.viewController?.showErrorPage(message: "Location access denied or restricted. Weather for your current location won't be displayed")
            case .locationUnknown:
                self.viewController?.showErrorPage(message: "Unable to determine location. Please try again.")
            default:
                self.viewController?.showErrorPage(message: "Error")
            }
        } else {
            self.viewController?.showErrorPage(message: "Error")
        }
    }
    
    func getCityNameFromLocation(_ location: CLLocation, completion: @escaping (String?) -> Void) {        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    // Show error page for geocoding failure
                    self.viewController?.showErrorPage(message: "Unable to determine your location. Please try again.")
                    completion(nil)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self.viewController?.showErrorPage(message: "No location information found.")
                    completion(nil)
                    return
                }
                
                // Get the city name from the placemark
                let cityName = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea ?? "Unknown"
                
                self.viewController?.currentLocationCityName = cityName // Store the city name
                completion(cityName)
            }
        }
    }
}

protocol WeatherViewControllerDelegate: AnyObject {
    var currentLocationCityName: String? { get set }
   // var activityIndicator: UIActivityIndicatorView
    //func refreshCollectionView()
    var collectionView: UICollectionView {get}
    func fetchWeather(for city: String)
    func fetchWeatherForCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    func showErrorPage(message: String)
    //func updateCurrentLocationWeather(weather: Weather?)
}
