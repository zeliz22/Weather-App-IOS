import UIKit
import Kingfisher


class FiveDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var city: String
    struct ForecastEntry {
        let time: String
        let temp: Int
        let description: String
        let icon: String
    }
    
    private var forecastData: [String: [ForecastEntry]] = [:]
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var sortedWeekdays: [String] = []
    
    init(city: String) {
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = city
        view.backgroundColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
        
        setupNavigationBarAppearance()
        setupTableView()
        setupActivityIndicator()
        fetchWeatherForecast()
    }
    
    private func setupNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            
            appearance.backgroundColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.isTranslucent = false
        } else {
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.yellow,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
            navigationController?.navigationBar.isTranslucent = false
        }
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .yellow
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: "ForecastCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchWeatherForecast() {
        activityIndicator.startAnimating()
        let apiKey = "0fa034786a46e9c28007a2cd1746142a"
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data), apiError.cod != "200" {
                    print("API Error: \(apiError.message)")
                    return
                }
                
                let result = try JSONDecoder().decode(WeatherResponse.self, from: data)
                self?.processForecastData(result.list)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    private func processForecastData(_ list: [WeatherEntry]) {
        var groupedData: [String: [ForecastEntry]] = [:]
        var dateKeys: [Date] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for entry in list {
            if let date = dateFormatter.date(from: entry.dt_txt) {
                let weekdayString = weekdayFormatter.string(from: date)
                let timeString = timeFormatter.string(from: date)
                let weatherDescription = entry.weather.first?.description ?? "Unknown"
                let iconID = entry.weather.first?.icon ?? "01d"  // Default icon if missing
                
                // Round the temperature to the nearest integer
                let roundedTemp = Int(entry.main.temp.rounded())
                
                let forecastEntry = ForecastEntry(time: timeString, temp: roundedTemp, description: weatherDescription, icon: iconID)
                
                if groupedData[weekdayString] == nil {
                    groupedData[weekdayString] = []
                    dateKeys.append(date) // Store the date for sorting
                }
                groupedData[weekdayString]?.append(forecastEntry)
            }
        }
        
        dateKeys.sort()
        
        let sortedWeekdays = dateKeys.map { weekdayFormatter.string(from: $0) }
        
        DispatchQueue.main.async {
            self.forecastData = groupedData
            self.sortedWeekdays = sortedWeekdays
            self.tableView.reloadData()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedWeekdays.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedWeekdays[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .yellow
            
            headerView.contentView.backgroundColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0) 
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sortedWeekdays[section]
        return forecastData[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell
        cell.backgroundColor = .clear

        let key = sortedWeekdays[indexPath.section]
        if let entry = forecastData[key]?[indexPath.row] {
            cell.timeLabel.text = entry.time
            cell.timeLabel.textColor = .white
            cell.descriptionLabel.text = entry.description
            cell.descriptionLabel.textColor = .white
            cell.temperatureLabel.text = "\(entry.temp)°C"
            cell.temperatureLabel.textColor = .yellow
            
            let iconURL = "https://openweathermap.org/img/wn/\(entry.icon)@2x.png"
            
            if let url = URL(string: iconURL) {
                       cell.weatherIcon.kf.setImage(with: url)
            }
        }
        
        return cell
    }
    
}

// Custom TableViewCell
class ForecastTableViewCell: UITableViewCell {
    let weatherIcon = UIImageView()
    let timeLabel = UILabel()
    let descriptionLabel = UILabel()
    let temperatureLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(weatherIcon)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(temperatureLabel)
        
        NSLayoutConstraint.activate([
            weatherIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weatherIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 40),
            weatherIcon.heightAnchor.constraint(equalToConstant: 40),
            
            timeLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            temperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        temperatureLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// API Error Handling Struct
struct APIError: Decodable {
    let cod: String
    let message: String
}

// Weather API Response Structs
struct WeatherResponse: Codable {
    let list: [WeatherEntry]
}

struct WeatherEntry: Codable {
    let dt_txt: String
    let main: MainInfo
    let weather: [WeatherDescription]
}

struct MainInfo: Codable {
    let temp: Double
}

struct WeatherDescription: Codable {
    let description: String
    let icon: String  // Add this to fetch the icon ID
}
