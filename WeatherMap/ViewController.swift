//
//  ViewController.swift
//  WeatherMap
//
//  Created by Ленар on 23.01.17.
//  Copyright © 2017 com.lenar. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, WeatherModelDeligate , CLLocationManagerDelegate {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var speedWindLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var time1Text:String!
    var time2Text:String!
    var time3Text:String!
    var time4Text:String!
    
    var icon1: UIImage!
    var icon2: UIImage!
    var icon3: UIImage!
    var icon4: UIImage!
    
    var temp1Text:String!
    var temp2Text:String!
    var temp3Text:String!
    var temp4Text:String!
    
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var openWeather = WeatherModel()
    var hud = MBProgressHUD()
    
    @IBAction func cityTappedButton(_ sender: UIBarButtonItem) {
        displayCity()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        //Set background
        
        let bg = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: bg!)
        
        //Set setup
        
        self.openWeather.deligate = self
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func addCity(_ sender: UIBarButtonItem) {
        displayCity()
    }
    
    func displayCity(){
        let alert = UIAlertController(title: "City", message: "Enter name city", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            textField.placeholder = "City name"
        }
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (action) in
            if let textField = alert.textFields?[0] {
                self.activityIndicator()
                self.openWeather.weatherFor(city: textField.text!)
                
            }
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func activityIndicator() -> Void {
        hud.label.text = "Loading..."
        hud.backgroundView.color = .gray
        self.view.addSubview(hud)
        hud.show(animated: true)
    }
    
    
    func updateWeatherInfo(weatherJson: JSON) {
        
        hud.hide(animated: true)
        
        if let tempResult = weatherJson["list"][0]["main"]["temp"].double {
            //Get country name
            let country = weatherJson["city"]["country"].stringValue
            //Get city name
            let cityName = weatherJson["city"]["name"].stringValue
            self.cityNameLabel.text = "\(cityName), \(country)"
            //Get time
            let now = Int(NSDate().timeIntervalSince1970)
            
            //let time = weatherJson["list"][0]["dt"].intValue
            let timeToString = openWeather.timeFromUnix(unixTime: now)
            self.timeLabel.text = "At \(timeToString) it is"
            //Get convert temperature
            let temperature = openWeather.convertTemperature(country: country, temperature: tempResult)
            self.tempLabel.text = "\(temperature)"
            //Get icon
            let weather = weatherJson["list"][0]["weather"][0]
            let condition = weather["id"].intValue
            let iconName = weather["icon"].stringValue
            let isNight = openWeather.isTimeNight(icon: iconName)
            openWeather.updateWeatherIcon(condition: condition, nightTime: isNight, index:0, weatherIcon: self.updateIconList)
            //self.iconImageView.image = icon
            //Get desctiption
            let desc = weather["description"].stringValue
            self.descriptionLabel.text = desc
            //Get speed wind
            let speed = weatherJson["list"][0]["wind"]["speed"].doubleValue
            self.speedWindLabel.text = "\(speed)"
            //Get humidity
            let humidity = weatherJson["list"]["0"]["main"]["humidity"].doubleValue
            self.humidityLabel.text = "\(humidity)"
            
            for index in 4...7 {
                if let tempResult = weatherJson["list"][index]["main"]["temp"].double{
                    //Get convert temperature
                    let forecastTemperature = openWeather.convertTemperature(country: country, temperature: tempResult)
                    
                    if index==4 {
                        temp1Text = forecastTemperature
                    } else if index==5 {
                        temp2Text = forecastTemperature
                    } else if index==6 {
                        temp3Text = forecastTemperature
                    } else if  index==7 {
                        temp4Text = forecastTemperature
                    }
                    
                    //Get forecast time
                    let forecastTime = weatherJson["list"][index]["dt"].intValue
                    let forecastTimeToString = openWeather.timeFromUnix(unixTime: forecastTime)
                    
                    if index==4 {
                        time1Text = forecastTimeToString
                    } else if index==5 {
                        time2Text = forecastTimeToString
                    } else if index==6 {
                        time3Text = forecastTimeToString
                    } else if  index==7 {
                        time4Text = forecastTimeToString
                    }
                    
                    //Get forecast icon
                    let weather = weatherJson["list"][index]["weather"][0]
                    let iconName = weather["icon"].stringValue
                    let isNight = openWeather.isTimeNight(icon: iconName)
                    openWeather.updateWeatherIcon(condition: condition, nightTime: isNight, index: index, weatherIcon:self.updateIconList)
                }
            }
            
        }else {
            print("Unable load weather info");
        }
    }
    
    func updateIconList(index: Int, name: String) {
        if (index == 0) {
            self.iconImageView.image = UIImage(named: name)
        }
        if (index == 4) {
            self.icon1 = UIImage(named: name)
        }
        if (index == 5) {
            self.icon2 = UIImage(named: name)
        }
        if (index == 6) {
            self.icon3 = UIImage(named: name)
        }
        if (index == 4) {
            self.icon4 = UIImage(named: name)
        }
    }
    
    func failure() {
        //No connection internet
        let networkController = UIAlertController(title: "Error", message: "No connection!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        networkController.addAction(okButton)
        present(networkController, animated: true, completion: nil)
        hud.hide(animated: true)
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(manager.location!)
        self.activityIndicator()
        let currentLocation = locations.last! as CLLocation
        
        if (currentLocation.horizontalAccuracy > 0) {
            
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            let coords = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            self.openWeather.weatherFor(geo: coords)
            print(coords)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        print("Can't get location")
    }
    
    //MARK: - prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreinfo" {
            let forecastController = segue.destination as! ForecastViewController
            forecastController.temp1 = self.temp1Text
            forecastController.temp2 = self.temp2Text
            forecastController.temp3 = self.temp3Text
            forecastController.temp4 = self.temp4Text
            
            forecastController.icon1Image = self.icon1
            forecastController.icon2Image = self.icon2
            forecastController.icon3Image = self.icon3
            forecastController.icon4Image = self.icon4
            
            forecastController.time1 = self.time1Text
            forecastController.time2 = self.time2Text
            forecastController.time3 = self.time3Text
            forecastController.time4 = self.time4Text
        }
    }
}

