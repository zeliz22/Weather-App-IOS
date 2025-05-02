import UIKit
import Kingfisher

class CityCell: UICollectionViewCell {
    let cityLabel = UILabel()
    let tempLabel = UILabel()
    let weatherIcon = UIImageView()
    
    let cloudinessIcon = UIImageView(image: UIImage(systemName: "cloud.fill"))
    let humidityIcon = UIImageView(image: UIImage(systemName: "drop.fill"))
    let windSpeedIcon = UIImageView(image: UIImage(systemName: "wind"))
    let windDirectionIcon = UIImageView(image: UIImage(systemName: "location.north.fill"))
    
    let cloudinessLabel = UILabel()
    let humidityLabel = UILabel()
    let windSpeedLabel = UILabel()
    let windDirectionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        layer.cornerRadius = 50
        layer.masksToBounds = true

        cityLabel.font = UIFont.boldSystemFont(ofSize: 18)
        cityLabel.textAlignment = .center

        tempLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        tempLabel.textAlignment = .center

        weatherIcon.contentMode = .scaleAspectFit

        [cloudinessLabel, humidityLabel, windSpeedLabel, windDirectionLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textAlignment = .right
            $0.textColor = .white
        }
        
        [cloudinessIcon, humidityIcon, windSpeedIcon, windDirectionIcon].forEach {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .yellow
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }

        let weatherDetailsStack = UIStackView(arrangedSubviews: [
            createDetailRow(icon: cloudinessIcon, label: "Cloudiness", valueLabel: cloudinessLabel),
            createDetailRow(icon: humidityIcon, label: "Humidity", valueLabel: humidityLabel),
            createDetailRow(icon: windSpeedIcon, label: "Wind Speed", valueLabel: windSpeedLabel),
            createDetailRow(icon: windDirectionIcon, label: "Wind Direction", valueLabel: windDirectionLabel)
        ])
        weatherDetailsStack.axis = .vertical
        weatherDetailsStack.spacing = 8
        weatherDetailsStack.alignment = .fill
        
        let space = UIStackView()
    

        let topStack = UIStackView(arrangedSubviews: [weatherIcon, cityLabel, tempLabel])
        topStack.axis = .vertical
        topStack.spacing = 4
        topStack.alignment = .center
        
    

        let mainStack = UIStackView(arrangedSubviews: [topStack, space, weatherDetailsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.alignment = .center

        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    func createDetailRow(icon: UIImageView, label: String, valueLabel: UILabel) -> UIStackView {
        let textLabel = UILabel()
        textLabel.text = label
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = .white

        let stack = UIStackView(arrangedSubviews: [icon, textLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }

    func configure(with city: String, weather: Weather) {
        // Set background color based on weather conditions
        backgroundColor = colorForWeather(weather)
        
        // Combine city and country
        let country = countryName(from: weather.sys.country)
        let cityAndCountry = "\(city), \(country)"
        cityLabel.text = cityAndCountry
        cityLabel.textColor = .white
        
        // Get the weather description
        if let description = weather.weather.first?.description {
            tempLabel.text = "\(weather.main.temp)°C | \(description)"
            tempLabel.textColor = .yellow
        }
        
        // Set weather icon
        if let iconCode = weather.weather.first?.icon {
            let iconUrl = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
            loadImage(from: iconUrl)
        }

        // Set weather details
        cloudinessLabel.text = "\(weather.clouds.all)%"
        humidityLabel.text = "\(weather.main.humidity)%"
        windSpeedLabel.text = "\(weather.wind.speed) m/s"
        windDirectionLabel.text = directionFromDegrees(weather.wind.deg)
    }

    private func colorForWeather(_ weather: Weather) -> UIColor {
        let temperatureCelsius = weather.main.temp // Assuming temperature is already in Celsius

        switch temperatureCelsius {
        case ..<10:
            return UIColor(red: 0.5, green: 0.7, blue: 0.8, alpha: 1.0) // Muted Blue (Cooler)
        case 10..<20:
            return UIColor(red: 0.6, green: 0.7, blue: 0.5, alpha: 1.0) // Muted Olive Green (Neutral)
        case 20..<25:
            return UIColor(red: 0.8, green: 0.7, blue: 0.4, alpha: 1.0) // Warm Mustard Yellow
        case 25..<30:
            return UIColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 1.0) // Soft Terracotta Orange
        case 30...:
            return UIColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 1.0) // Deep Brick Red (Less Intense)
        default:
            return UIColor(red: 0.4, green: 0.3, blue: 0.6, alpha: 1.0) // Muted Purple (Default)
        }
    }


    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        weatherIcon.kf.setImage(with: url)
    }

    private func directionFromDegrees(_ degrees: Int) -> String {
        switch degrees {
        case 0..<23: return "N"
        case 23..<68: return "NE"
        case 68..<113: return "E"
        case 113..<158: return "SE"
        case 158..<203: return "S"
        case 203..<248: return "SW"
        case 248..<293: return "W"
        case 293..<338: return "NW"
        default: return "N"
        }
    }
    
    func countryName(from countryCode: String) -> String {
        return Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode
    }
}

func createDetailRow(icon: UIImageView, label: String, valueLabel: UILabel) -> UIStackView {
        let textLabel = UILabel()
        textLabel.text = label
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = .white

        let stack = UIStackView(arrangedSubviews: [icon, textLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }


// MARK: - Weather Model
struct Weather: Codable {
    let main: Main
    let weather: [WeatherInfo]
    let wind: Wind
    let clouds: Clouds
    let name: String
    let sys: Sys // Add this for country
}

struct Sys: Codable {
    let country: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct WeatherInfo: Codable {
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}
