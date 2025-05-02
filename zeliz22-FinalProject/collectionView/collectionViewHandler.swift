//
//  collectionViewHandler.swift
//  zeliz22-FinalProject
//
//  Created by zaza elizbarashvili on 06/12/1403 AP.
//

import Foundation
import UIKit

class CollectionViewHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
     var viewController: ViewController
    init(viewController: ViewController) {
       self.viewController = viewController
   }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.width != 0 else { return }
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        viewController.pageControl.currentPage = Int(pageIndex)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewController.cities.count + (viewController.currentLocationWeather != nil ? 1 : 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCell", for: indexPath) as! CityCell
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true

        let shouldDisplayCurrentLocation = (indexPath.row == 0 && viewController.currentLocationWeather != nil && viewController.currentLocationCityName != nil)

        if shouldDisplayCurrentLocation {
            if let currentWeather = viewController.currentLocationWeather, let cityName = viewController.currentLocationCityName {
                cell.configure(with: cityName, weather: currentWeather)
            }
        } else {

            let cityIndex = indexPath.row - (viewController.currentLocationWeather != nil ? 1 : 0)
            
            guard cityIndex >= 0, cityIndex < viewController.cities.count else {
                return cell
            }
            
            let city = viewController.cities[cityIndex]
            if let name = city.value(forKey: "name") as? String, let weather = viewController.weatherData[name] {
                cell.configure(with: name, weather: weather)
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set the cell size to 70% of the collection view width
        let width = collectionView.frame.width * 0.7
        let height = collectionView.frame.height * 0.9
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cityName: String?

        // Determine the city name for the selected cell
        if indexPath.item == 0, let currentWeather = viewController.currentLocationWeather {
            cityName = currentWeather.name
        } else {
            let cityIndex = indexPath.item - (viewController.currentLocationWeather != nil ? 1 : 0)
            if cityIndex < viewController.cities.count, let name = viewController.cities[cityIndex].value(forKey: "name") as? String {
                cityName = name
            }
        }

        // Ensure cityName is not nil before pushing the view controller
        if let cityName = cityName {
            let fiveDayVC = FiveDayViewController(city: cityName)
            viewController.navigationController?.pushViewController(fiveDayVC, animated: true)
        }
    }
}
