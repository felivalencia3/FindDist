//
//  ViewController.swift
//  FindDist2
//
//  Created by Felipe Valencia  on 10/10/18.
//  Copyright © 2018 Felipe Valencia . All rights reserved.
//
extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
import MapKit
import CoreLocation
import Foundation
import UIKit
import Alamofire
class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
	@IBOutlet weak var input: UITextField!
	@IBOutlet weak var result: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func findDistance(_ sender: UIButton) {
        print("button pressed")
        
        if (CLLocationManager.locationServicesEnabled())
        {
            print("Services Enabled")
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating Location")
     let currentLocation = locations.last! as CLLocation
        findDist(currentLocation)
    }
    func findDist(_ currentLocation: CLLocation)  {
        print("finding distance")
        let str_adress = input.text
        if (str_adress != nil) {
        let params = str_adress!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = "http://www.mapquestapi.com/geocoding/v1/address?key=knTACfthNjNUXehownmiFKqOjxOW4Sd9&location="+params!
        Alamofire.request(url).responseJSON { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                let latLngindex = utf8Text.index(of: "latLng")
                let displayindex = utf8Text.index(of: "display")
                var coords = utf8Text.suffix(from: latLngindex!).prefix(upTo: displayindex!)
                coords = coords.suffix(35)
                coords.remove(at: coords.index(before: coords.endIndex))
                coords.remove(at: coords.index(before: coords.endIndex))
                coords.remove(at: coords.index(before: coords.endIndex))
                
                let commaindex = coords.firstIndex(of: ",")
                var lat = coords.prefix(upTo: commaindex!)
                var long = coords.suffix(from: commaindex!)
                let latcolonindex = lat.firstIndex(of: ":")
                let longcolonindex = long.firstIndex(of: ":")
                lat = lat.suffix(from: latcolonindex!)
                long = long.suffix(from: longcolonindex!)
                lat.remove(at: lat.startIndex)
                long.remove(at: long.startIndex)
                //lat and long complete here
                let latitude_str = String(lat)
                let longitude_str = String(long)
                let latitude = Double(latitude_str)
                let longitude = Double(longitude_str)
                let latDegree: CLLocationDegrees = latitude!
                let longDegree: CLLocationDegrees = longitude!
                let otherLocation: CLLocation = CLLocation(latitude: latDegree, longitude: longDegree)
                print("Other ",otherLocation.coordinate)
                print("Current ",currentLocation.coordinate)
                let distance = ceil(otherLocation.distance(from: currentLocation))
                self.result.text = "The distance from your current location and the address you gave us is \(distance) meters or \(distance*0.001) KM"
            }
        }
        
        } else {print("No Address Given")}
    
}

}
