//
//  WeatherModel.swift
//  WeatherMap
//
//  Created by Ленар on 23.01.17.
//  Copyright © 2017 com.lenar. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation

protocol WeatherModelDeligate {
    func updateWeatherInfo(weatherJson:JSON)
    func failure()
}

class WeatherModel {
    
    let weatherURL = "http://api.openweathermap.org/data/2.5/forecast"
    
    var deligate: WeatherModelDeligate!
    
    func weatherFor(city:String) {
        let params = ["q" : city, "APPID" : "5de039590ab31191bd0a9f613c93588d"]
        setRequest(params: params as [String : AnyObject]?);
    }
    
    func timeFromUnix(unixTime:Int) -> String {
        let timeInSecond = TimeInterval(unixTime)
        let weatherDate = Date(timeIntervalSince1970: timeInSecond)
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "hh:mm"
        let date = dateFormatter.string(from: weatherDate as Date)
        return date
    }
    
    func weatherFor(geo: CLLocationCoordinate2D) {
        let params = ["lat" : geo.latitude, "lon" : geo.longitude, "APPID" : "5de039590ab31191bd0a9f613c93588d"] as [String : Any]
        setRequest(params: params as [String:AnyObject])
    }
    
    func setRequest(params:[String:AnyObject]?) {
        
        request(weatherURL, method: .get, parameters: params).responseJSON { (resp) in
            
            if (resp.error != nil){
                self.deligate.failure()
            }else{
                let weatherJson = JSON(resp.result.value!)
                DispatchQueue.main.async {
                    self.deligate.updateWeatherInfo(weatherJson: weatherJson)
                }
            }
        }
    }
    
    func convertTemperature(country:String, temperature:Double) -> String {
        let deg:Int
        let str:String
        if (country == "US") {
            deg = Int(round(((temperature-273.15)*1.8)+32))
            str = "\(deg)℉"
        } else {
            deg = Int(round(temperature - 273.15))
            str = "\(deg)℃"
        }
        return str
    }
    
    func updateWeatherIcon(condition: Int, nightTime: Bool, index: Int, weatherIcon:(_ index: Int, _ icon: String) ->()) {
        
        switch (condition, nightTime) {
            
            
        //Thunderstorm
        case let (x,y) where x < 300 && y == true:  weatherIcon(index, "11n")
        case let (x,y) where x < 300 && y == false: weatherIcon(index, "11d")
            
        //Drizzle
        case let (x,y) where x < 500 && y == true:  weatherIcon(index, "09n")
        case let (x,y) where x < 500 && y == false: weatherIcon(index, "09d")
            
        //Rain
        case let (x,y) where x <= 504 && y == true:  weatherIcon(index, "10n")
        case let (x,y) where x <= 504 && y == false: weatherIcon(index, "10d")
            
        case let (x,y) where x == 511 && y == true:  weatherIcon (index,
                                                                  
                                                                  "13n")
        case let (x,y) where x == 511 && y == false: weatherIcon(index, "13d")
            
        case let (x,y) where x < 600 && y == true:  weatherIcon(index, "09n")
        case let (x,y) where x < 600 && y == false: weatherIcon(index, "09d")
            
        //Snow
        case let (x,y) where x < 700 && y == true:  weatherIcon(index, "13n")
        case let (x,y) where x < 700 && y == false: weatherIcon(index, "13n")
            
        //Atmosphere
        case let (x,y) where x < 800 && y == true:  weatherIcon(index, "50n")
        case let (x,y) where x < 800 && y == false: weatherIcon(index, "50d")
            
        //Clouds
        case let (x,y) where x == 800 && y == true:  weatherIcon(index, "01n")
        case let (x,y) where x == 800 && y == false: weatherIcon(index, "01d")
            
        case let (x,y) where x == 801 && y == true:  weatherIcon(index, "02n")
        case let (x,y) where x == 801 && y == false: weatherIcon(index, "02d")
            
        case let (x,y) where x > 802 || x < 804 && y == true:  weatherIcon(index, "03n")
        case let (x,y) where x > 802 || x < 804 && y == false:  weatherIcon(index, "02d")
            
        case let (x,y) where x == 804 && y == true:  weatherIcon(index, "04n")
        case let (x,y) where x == 804 && y == false: weatherIcon(index, "04d")
            
        //Additional
        case let (x,y) where x < 1000 && y == true:  weatherIcon(index, "11n")
        case let (x,y) where x < 1000 && y == false: weatherIcon(index, "11d")
            
        case let (x,y): weatherIcon(index, "none")
        }
    }
    
    func isTimeNight(icon:String) -> Bool {
        return icon.range(of: "n") != nil
    }
    
}
