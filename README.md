# Weather App (iOS)

A simple iOS weather app built with Swift and UIKit. Users can search for cities, view current weather, and see a 5-day forecast. The app is designed to be production-ready with full error handling and loading indicators.

---

## Features

- Search and add new cities by name
- View current weather for:
  - Current location
  - Saved cities
- Tap a city to view detailed 5-day forecast (grouped by day, updated every 3 hours)
- Long press on a city to delete it (with confirmation alert)
- Refresh weather data manually
- Local storage for saved cities
- Location detection on first launch
- Loading indicators and error messages for better user experience
- Data fetched from OpenWeatherMap API:
  - Current weather: https://openweathermap.org/current
  - 5-day forecast: https://openweathermap.org/forecast5

---

## Technologies Used

- Swift
- UIKit
- CoreLocation
- URLSession
- SDWebImage or Kingfisher (for image downloading and caching)
- UserDefaults (for local data storage)

---
