//
//  ViewController.swift
//  MyWeather
//
//  Created by Luke Martin-Resnick on 10/19/20.
//

import UIKit
import CoreLocation


// Location: CoreLocation
// table view
// custom cell: collection view
// API / Request to get data

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    
    var models = [ForecastDay]()
    var hourModels = [Hour]()
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    var current: CurrentWeather?
    var textLocation : Location?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register 2 cells
        
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    // Location
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let apiKey = "50004d21383c4d9b96b33454202010"
        
        let url = "http://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(lat),\(long)&days=5"
        print(url)
        print(lat)
        print(long)
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            // Validation
            
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            
            // Convert data to models/some object
            
            var json : WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                print("error: \(error)")
            }
            
            guard let result = json else {
                return
            }
            print(result)
            
            let entries = result.forecast.forecastday
            self.models.append(contentsOf: entries)
            
            let current = result.current
            self.current = current
            
            let textLocation = result.location
            self.textLocation = textLocation
            
            //self.hourModels = result.forecast.forecastday
            
            
            // Update User Interface
            
            DispatchQueue.main.async {
                self.table.reloadData()
                
                self.table.tableHeaderView = self.createTableHeader()
            }
        }.resume()
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        
        headerView.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        
        
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 40, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let iconImage = UIImageView(frame: CGRect(x: headerView.frame.size.width/4, y: locationLabel.frame.size.height+summaryLabel.frame.size.height, width: headerView.frame.size.height/2, height: headerView.frame.size.height/2))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+iconImage.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))
        
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(iconImage)
        
        //iconImage.contentMode = .scaleAspectFit
        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        
        tempLabel.textColor = .white
        locationLabel.textColor = .white
        summaryLabel.textColor = .white
        
        
        
        guard let currentWeather = self.current else {
            return UIView()
        }
        
        guard let currentTextLocation = self.textLocation else {
            return UIView()
        }
        //locationLabel.text = "\(currentTextLocation.name)"
        
        locationLabel.text = "\(currentTextLocation.name)"//", \(currentTextLocation.region)"
        locationLabel.font = UIFont(name: "Helvetica", size: 36)
        tempLabel.text = "\(currentWeather.temp_f)°F"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        summaryLabel.text = currentWeather.condition.text
        summaryLabel.font = UIFont(name: "Helvetica", size: 24)
        
        
        let weatherIcon = currentWeather.condition.text.lowercased()
        if weatherIcon.contains("sun") || weatherIcon.contains("clear") {
            iconImage.image = UIImage(named: "sun")
        } else if weatherIcon.contains("rain") {
            iconImage.image = UIImage(named: "rain")
        } else {
            iconImage.image = UIImage(named: "cloud")
        }
        
        return headerView
    }
    
    
    // Table
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 1 cell that is a collection view
            return 1
        }
        
        print(models.count)
        return models.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourModels)
            cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}

struct WeatherResponse: Codable {
    let location : Location
    let current : CurrentWeather
    let forecast : Forecast
}


struct Location: Codable {
    let name : String
    let region : String
    let country : String
    let lat : Float
    let lon : Float
    let tz_id : String
    let localtime_epoch : Int
    let localtime : String
}

struct CurrentWeather: Codable {
    let last_updated_epoch : Int
    let last_updated : String
    let temp_c : Float
    let temp_f : Float
    let is_day : Int
    let condition : ConditionCurrent
    let wind_mph : Float
    let wind_kph : Float
    let wind_degree : Int
    let wind_dir : String
    let pressure_mb : Float
    let pressure_in : Float
    let precip_mm : Float
    let precip_in : Float
    let humidity : Int
    let cloud : Int
    let feelslike_c : Float
    let feelslike_f : Float
    let vis_km : Float
    let vis_miles : Float
    let uv : Float
    let gust_mph : Float
    let gust_kph : Float
    
}
struct ConditionCurrent: Codable {
    let text : String
    let icon : String
    let code : Int
}

struct Forecast: Codable {
    let forecastday : [ForecastDay]
}



struct ForecastDay: Codable {
    let date : String
    let date_epoch : Int
    let day : Day
    let astro : Astro
    let hour : [Hour]
}

struct Day: Codable {
    let maxtemp_c : Float
    let maxtemp_f : Float
    let mintemp_c : Float
    let mintemp_f : Float
    let avgtemp_c : Float
    let avgtemp_f : Float
    let maxwind_mph : Float
    let maxwind_kph : Float
    let totalprecip_mm : Float
    let totalprecip_in : Float
    let avgvis_km : Float
    let avgvis_miles : Float
    let avghumidity : Float
    let daily_will_it_rain : Int
    let daily_chance_of_rain : String
    let daily_will_it_snow : Int
    let daily_chance_of_snow : String
    let condition : ConditionDay
    let uv : Float
}

struct ConditionDay: Codable {
    let text : String
    let icon : String
    let code : Int
    
}

struct Astro: Codable {
    let sunrise : String
    let sunset : String
    let moonrise : String
    let moonset : String
    let moon_phase : String
    let moon_illumination : String
}

struct Hour: Codable {
    let time_epoch : Int
    let time : String
    let temp_c : Float
    let temp_f : Float
    let is_day : Int
    let condition : ConditionHour
    let wind_mph : Float
    let wind_kph : Float
    let wind_degree : Int
    let wind_dir : String
    let pressure_mb : Float
    let pressure_in : Float
    let precip_mm : Float
    let precip_in : Float
    let humidity : Int
    let cloud : Int
    let feelslike_c : Float
    let feelslike_f : Float
    let windchill_c : Float
    let windchill_f : Float
    let heatindex_c : Float
    let heatindex_f : Float
    let dewpoint_c : Float
    let dewpoint_f : Float
    let will_it_rain : Int
    let chance_of_rain : String
    let will_it_snow : Int
    let chance_of_snow : String
    let vis_km : Float
    let vis_miles : Float
    let gust_mph : Float
    let gust_kph : Float
}

struct ConditionHour: Codable {
    let text : String
    let icon : String
    let code : Int
}


