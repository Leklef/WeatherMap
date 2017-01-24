//
//  ViewController.swift
//  WeatherMap
//
//  Created by Ленар on 23.01.17.
//  Copyright © 2017 com.lenar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WeatherModelDeligate {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var CityLabel: UILabel!
    
    var openWeather = WeatherModel()
    
    @IBAction func cityTappedButton(_ sender: UIBarButtonItem) {
        displayCity()
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openWeather.deligate = self
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
                self.openWeather.getWeatherFor(city: textField.text!)
            }
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func updateWeatherInfo(weatherJson: JSON) {
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
    
}

