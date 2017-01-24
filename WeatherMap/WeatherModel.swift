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

protocol WeatherModelDeligate {
    func updateWeatherInfo(weatherJson:JSON)
}

class WeatherModel {
    
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather"
    
    var deligate: WeatherModelDeligate!
    
    func getWeatherFor(city:String) {
        let params = ["q" : city, "APPID" : "8349c4ca0a04952928760a6c2e2c4438"]
        setRequest(params: params as [String : AnyObject]?);
    }
    
    func timeFromUnix(unixTime:Int) -> String {
        let timeInSecond = TimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSecond)
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:MM"
        return dateFormatter.string(from: weatherDate as Date)
    }
    
    func setRequest(params:[String:AnyObject]?) {
        
        request(weatherURL, method: .get, parameters: params).responseJSON { (resp) in
            let weatherJson = JSON(resp.result.value!)
            
            DispatchQueue.main.async {
                self.deligate.updateWeatherInfo(weatherJson: weatherJson)
            }
        }
    }
    
    func convertTemperature(country:String, temperature:Double) -> Double {
        if (country == "US") {
            return round(((temperature-273.15)*1.8)+32)
        } else {
            return round(temperature - 273.15)
        }
    }
    
    func updateWeatherIcon(condition: Int, nightTime: Bool) -> UIImage {
        var imageName:String
        switch (condition,nightTime) {
        case let(x,y) where x<300 && y==true:imageName = "11n"
        case let(x,y) where x<300 && y==false:imageName = "11d"
        case let(x,y) where x<500 && y==true:imageName = "09n"
        case let(x,y) where x<500 && y==false:imageName = "09d"
        case let(x,y) where x<=504 && y==true:imageName = "10n"
        case let(x,y) where x<=504 && y==false:imageName = "10d"
        case let(x,y) where x==511 && y==true:imageName = "13n"
        case let(x,y) where x==511 && y==false:imageName = "13d"
        case let(x,y) where x<600 && y==true:imageName = "09n"
        case let(x,y) where x<600 && y==false:imageName = "09d"
        case let(x,y) where x<700 && y==true:imageName = "13n"
        case let(x,y) where x<700 && y==false:imageName = "13d"
        case let(x,y) where x<800 && y==true:imageName = "50n"
        case let(x,y) where x<800 && y==false:imageName = "50d"
        case let(x,y) where x==800 && y==true:imageName = "01n"
        case let(x,y) where x==800 && y==false:imageName = "01d"
        case let(x,y) where x==801 && y==true:imageName = "02n"
        case let(x,y) where x==801 && y==false:imageName = "02d"
        case let(x,y) where x>=802 || x<804 && y==true:imageName = "03n"
        case let(x,y) where x>=802 || x<804 && y==false:imageName = "03d"
        case let(x,y) where x==804 && y==true:imageName = "04n"
        case let(x,y) where x==804 && y==false:imageName = "04d"
        case let(x,y) where x>=900 && y==true:imageName = "11n"
        case let(x,y) where x>=900 && y==false:imageName = "11d"
        default:
            imageName = "none"
        }
        let iconImage = UIImage(named: imageName)
        return iconImage!
    }
    
    func isTimeNight(weatherJson:JSON) -> Bool {
        var nightTime = false
        let nowTime = NSDate().timeIntervalSince1970
        let sunrise = weatherJson["sys"]["sunrise"].doubleValue
        let sunset = weatherJson["sys"]["sunrise"].doubleValue
        if (nowTime < sunrise && nowTime > sunset){
            nightTime = true
        }
        
        return nightTime
    }

    
}
