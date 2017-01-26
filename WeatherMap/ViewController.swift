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
    @IBOutlet weak var CityLabel: UILabel!
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var openWeather = WeatherModel()
    var hud = MBProgressHUD()
    
    @IBAction func cityTappedButton(_ sender: UIBarButtonItem) {
        displayCity()
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openWeather.deligate = self
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
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
        
        if let tempResult = weatherJson["main"]["temp"].double {
            let country = weatherJson["sys"]["country"].stringValue
            let cityName = weatherJson["name"].stringValue
            print(cityName)
            let temperature = openWeather.convertTemperature(country: country, temperature: tempResult)
            print(temperature)
            let weather = weatherJson["weather"][0]
            let condition = weather["id"].intValue
            let isNight = openWeather.isTimeNight(weatherJson: weatherJson)
            let icon = openWeather.updateWeatherIcon(condition: condition, nightTime: isNight)
            self.iconImageView.image = icon
        }else {
            print("Unable load weather info");
        }
    }
    
    func failure() {
        //No connection internet
        let networkController = UIAlertController(title: "Error", message: "No connection!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        networkController.addAction(okButton)
        present(networkController, animated: true, completion: nil)
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
}

