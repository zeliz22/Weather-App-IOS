//
//  WeatherService.swift
//  zeliz22-FinalProject
//
//  Created by zaza elizbarashvili on 06/12/1403 AP.
//

import Foundation
import UIKit
import CoreLocation

class WeatherService {
    var viewController: ViewController?
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func fetchWeather(for city: String) {
        guard let viewController = viewController,
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=0fa034786a46e9c28007a2cd1746142a&units=metric") else { return }
        
        viewController.activityIndicator.startAnimating()

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let viewController = self.viewController else { return }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    viewController.showErrorPage(message: "Network Error: Failed to fetch weather data for \(city)")
                }
                return
            }

            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    viewController.weatherData[city] = weather
                    viewController.collectionView.reloadData()
                    viewController.activityIndicator.stopAnimating()
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    viewController.showErrorPage(message: "Decoding error: Please, check API links")
                }
            }
        }.resume()
    }

    func fetchWeatherForCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        guard let viewController = viewController,
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=0fa034786a46e9c28007a2cd1746142a&units=metric") else { return }
        
        viewController.activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let viewController = self.viewController else { return }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    viewController.showErrorPage(message: "Network Error: Failed to fetch weather data for your current location")
                }
                return
            }

            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    viewController.currentLocationWeather = weather
                    viewController.collectionView.reloadData()
                    viewController.activityIndicator.stopAnimating()
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    viewController.showErrorPage(message: "Decoding error for your current location: Please, check your API link")
                }
            }
        }.resume()
    }
    
    func refreshWeather() {
        guard let viewController = viewController else { return }
        
        // Clear existing data
        viewController.weatherData.removeAll()
        viewController.currentLocationWeather = nil
        
        // Hide collection view and page control
        viewController.collectionView.isHidden = true
        viewController.pageControl.isHidden = true
        
        // Show and center activity indicator
        viewController.activityIndicator.center = viewController.view.center
        viewController.activityIndicator.startAnimating()
        viewController.view.bringSubviewToFront(viewController.activityIndicator)
        
        // Start updating location if authorized
        if viewController.locationManager.authorizationStatus == .authorizedWhenInUse ||
           viewController.locationManager.authorizationStatus == .authorizedAlways {
            viewController.locationManager.startUpdatingLocation()
        }
        
        // Refresh weather for all saved cities
        let citiesCount = viewController.cities.count
        if citiesCount == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                viewController.activityIndicator.stopAnimating()
                viewController.collectionView.isHidden = false
                viewController.pageControl.isHidden = false
                viewController.collectionView.reloadData()
            }
            return
        }
        
        for city in viewController.cities {
            if let name = city.value(forKey: "name") as? String {
                fetchWeather(for: name)
            }
        }
        
        var checkTimer: Timer?
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, let viewController = self.viewController else {
                timer.invalidate()
                return
            }
            
            let citiesWithWeather = viewController.cities.filter { city in
                if let name = city.value(forKey: "name") as? String {
                    return viewController.weatherData[name] != nil
                }
                return false
            }
            
            let shouldWaitForLocation = viewController.locationManager.authorizationStatus == .authorizedWhenInUse ||
                                      viewController.locationManager.authorizationStatus == .authorizedAlways
            
            let allDataLoaded = citiesWithWeather.count == viewController.cities.count &&
                               (viewController.currentLocationWeather != nil || !shouldWaitForLocation)
            
            if allDataLoaded {
                timer.invalidate()
                checkTimer = nil
                viewController.collectionView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    viewController.activityIndicator.stopAnimating()
                    viewController.collectionView.isHidden = false
                    viewController.pageControl.isHidden = false
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) { [weak self] in
            checkTimer?.invalidate()
            checkTimer = nil
            
            guard let viewController = self?.viewController else { return }
            
            DispatchQueue.main.async {
                viewController.collectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    viewController.activityIndicator.stopAnimating()
                    viewController.collectionView.isHidden = false
                    viewController.pageControl.isHidden = false
                }
            }
        }
    }
}
