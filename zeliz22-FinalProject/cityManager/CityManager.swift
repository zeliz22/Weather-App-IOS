//
//  CityManager.swift
//  zeliz22-FinalProject
//
//  Created by zaza elizbarashvili on 06/12/1403 AP.
//

import Foundation
import UIKit
import CoreData

class CityManager {
    weak var viewController: ViewController?
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func addCity() {
        guard let viewController = viewController else { return }
        
        let addCityVC = AddCityViewController()
        addCityVC.modalPresentationStyle = .overCurrentContext
        addCityVC.modalTransitionStyle = .crossDissolve
        addCityVC.onAddCity = { [weak self] cityName in
            guard let self = self else { return }
            
            // Check if the city already exists
            if self.isCityAlreadyAdded(cityName) {
                DispatchQueue.main.async {
                    addCityVC.showError(message: "\(cityName) is already in the list or is your current location.")
                    addCityVC.stopLoading()
                }
                return
            }
            
            // Validate and save the city
            self.validateAndSaveCity(name: cityName) { success in
                DispatchQueue.main.async {
                    if success {
                        addCityVC.dismiss(animated: true)
                    } else {
                        addCityVC.showError(message: "Error Occurred. Invalid city name")
                        addCityVC.stopLoading()
                    }
                }
            }
        }
        viewController.present(addCityVC, animated: true)
    }
    
    func isCityAlreadyAdded(_ cityName: String) -> Bool {
        guard let viewController = viewController else { return false }
        
        // Check if the city is the current location
        if let currentLocationCityName = viewController.currentLocationCityName,
           currentLocationCityName.lowercased() == cityName.lowercased() {
            return true
        }
        
        // Check if the city is already in the list
        for city in viewController.cities {
            if let name = city.value(forKey: "name") as? String,
               name.lowercased() == cityName.lowercased() {
                return true
            }
        }
        
        return false
    }
    
    func validateAndSaveCity(name: String, completion: @escaping (Bool) -> Void) {
        guard let viewController = viewController,
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(name)&appid=0fa034786a46e9c28007a2cd1746142a&units=metric") else {
            completion(false)
            return
        }
        
        viewController.activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let viewController = self.viewController else { return }
            
            DispatchQueue.main.async {
                viewController.activityIndicator.stopAnimating()
                
                if let error = error {
                    completion(false)
                    return
                }

                guard let data = data else {
                    completion(false)
                    return
                }
                do {
                    let weather = try JSONDecoder().decode(Weather.self, from: data)
                    viewController.weatherData[name] = weather
                    self.saveCityToCoreData(name: name)
                    viewController.collectionView.reloadData()
                    completion(true)
                } catch {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func saveCityToCoreData(name: String) {
        guard let viewController = viewController,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "City", in: context)!
        let city = NSManagedObject(entity: entity, insertInto: context)
        city.setValue(name, forKey: "name")

        do {
            try context.save()
            viewController.cities.append(city)
            viewController.collectionView.reloadData()
            viewController.viewWillLayoutSubviews()
        } catch {
            // Error handling
        }
    }
    
    func loadCities() {
        guard let viewController = viewController,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "City")

        // Fetch saved cities
        do {
            viewController.cities = try context.fetch(fetchRequest)
            for city in viewController.cities {
                if let name = city.value(forKey: "name") as? String {
                    viewController.fetchWeather(for: name)
                }
            }
        } catch {
            print("Failed to fetch cities: \(error.localizedDescription)")
        }
    }
    
    func deleteCity(_ city: NSManagedObject) {
        guard let viewController = viewController,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        context.delete(city)

        do {
            try context.save()
            viewController.cities.removeAll { $0 == city }
            viewController.collectionView.reloadData()
            viewController.viewWillLayoutSubviews()
        } catch {
            print("Failed to delete city: \(error.localizedDescription)")
        }
    }
    
    func showActionSheet(for city: NSManagedObject) {
        guard let viewController = viewController else { return }
        
        let cityName = city.value(forKey: "name") as! String
        let actionSheet = UIAlertController(title: "Are you sure you want to remove \(cityName)?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteCity(city)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
}
