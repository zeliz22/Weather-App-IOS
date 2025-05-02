import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, WeatherViewControllerDelegate {
    
    



    // MARK: - Properties
    var locationManager = CLLocationManager()
    var cities: [NSManagedObject] = []
    var weatherData: [String: Weather] = [:]
    var currentLocationWeather: Weather?
    var currentLocationCityName: String?
    private var collectionViewHandler: CollectionViewHandler!
    private var weatherLocationManager: WeatherLocationManager!
    private var cityManager: CityManager!
    private var uiManager: UIManager!

    let collectionView: UICollectionView = {
           let layout = PagingFlowLayout()
           let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
           cv.backgroundColor = .clear
           cv.register(CityCell.self, forCellWithReuseIdentifier: "CityCell")
           return cv
       }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .yellow
        pc.pageIndicatorTintColor = .white
        pc.hidesForSinglePage = true
        return pc
    }()
    
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cityManager = CityManager(viewController: self)
        weatherLocationManager = WeatherLocationManager(viewController: self)
        uiManager = UIManager(viewController: self)
        collectionViewHandler = CollectionViewHandler(viewController: self)
      
        uiManager.setupUI()
        uiManager.setupNavigationBarAppearance()
        
        collectionView.dataSource = collectionViewHandler
        collectionView.delegate = collectionViewHandler
        
        weatherLocationManager.checkLocationAuthorization()
        cityManager.loadCities()
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let newPageCount = cities.count + (currentLocationWeather != nil ? 1 : 0)
        if pageControl.numberOfPages != newPageCount {
            pageControl.numberOfPages = newPageCount
        }
    }


 //   MARK: - Fetch Weather Data
    func fetchWeather(for city: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=0fa034786a46e9c28007a2cd1746142a&units=metric") else { return }
        
        activityIndicator.startAnimating()

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorPage(message: "Network Error: Failed to fetch weather data for \(city)")
                }
                return
            }

            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData[city] = weather
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorPage(message: "Decoding error: Please, check API links")
                }
            }
        }.resume()
    }

    func fetchWeatherForCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=0fa034786a46e9c28007a2cd1746142a&units=metric") else { return }
        activityIndicator.startAnimating()

       
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorPage(message: "Network Error: Failed to fetch weather data for your current locatoin")
                }
                return
            }

            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    self.currentLocationWeather = weather
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorPage(message: "Decoding error for you current location: Please, check you API link")
                }
            }
        }.resume()
    }
    
    
    //MARK: refreshWeather
    @objc func refreshWeather() {
        // Clear existing data
        weatherData.removeAll()
        currentLocationWeather = nil
        
        // Hide collection view and page control
        collectionView.isHidden = true
        pageControl.isHidden = true
        
        // Show and center activity indicator
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
        // Start updating location if authorized
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
        // Refresh weather for all saved cities
        let citiesCount = cities.count
        if citiesCount == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.activityIndicator.stopAnimating()
                self.collectionView.isHidden = false
                self.pageControl.isHidden = false
                self.collectionView.reloadData()
            }
            return
        }
        
        for city in cities {
            if let name = city.value(forKey: "name") as? String {
                fetchWeather(for: name)
            }
        }
        var checkTimer: Timer?
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let citiesWithWeather = self.cities.filter { city in
                if let name = city.value(forKey: "name") as? String {
                    return self.weatherData[name] != nil
                }
                return false
            }
            
            let shouldWaitForLocation = self.locationManager.authorizationStatus == .authorizedWhenInUse ||
                                      self.locationManager.authorizationStatus == .authorizedAlways
            
            let allDataLoaded = citiesWithWeather.count == self.cities.count &&
                               (self.currentLocationWeather != nil || !shouldWaitForLocation)
            
            if allDataLoaded {
                timer.invalidate()
                checkTimer = nil
                self.collectionView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.isHidden = false
                    self.pageControl.isHidden = false
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) { [weak self] in
            checkTimer?.invalidate()
            checkTimer = nil
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.isHidden = false
                    self?.pageControl.isHidden = false
                }
            }
        }
    }
    
    @objc func addCity() {
        cityManager.addCity()
    }
    

    // MARK: - Error Handling
    func showErrorPage(message: String) {
        if navigationController?.topViewController is ErrorViewController {
               return
           }

        let errorVC = ErrorViewController(message: message)
               errorVC.reloadAction = { [weak self] in
                   self?.refreshWeather()
               }
               navigationController?.pushViewController(errorVC, animated: true)
    }

    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                if indexPath.row == 0, currentLocationWeather != nil {
                    // Show a message that the current location city cannot be removed
                    let alert = UIAlertController(title: "Cannot Remove", message: "You can't remove your current location city.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                } else {
                    let city = cities[indexPath.row - (currentLocationWeather != nil ? 1 : 0)]
                    cityManager.showActionSheet(for: city)
                }
            }
        }
    }
}
