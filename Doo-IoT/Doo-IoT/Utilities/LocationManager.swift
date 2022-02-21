//
//  LocationManager.swift
//  techne
//
//  Created by Nicholas LoGioco on 3/22/17.
//  Copyright © 2017 Techne Technologies. All rights reserved.
//

import Foundation
import CoreLocation
import ContactsUI

protocol LocationManagerDelegate {
    func locationFound(withCoordinates coordinates : CLLocationCoordinate2D)
    func locationDenied()
}

class LocationManager : NSObject {
    private static let sharedInstance = LocationManager()
    
    public var manager : CLLocationManager?
    var delegate : LocationManagerDelegate!

    struct LocationDataModel {
        var city = ""
        var state = ""
        var country = ""
        var lat: Double = 0.0
        var long: Double = 0.0
        var manualLocation = "" // If lat long not assigned.
        var latFormattedString: String {
            return String(format: "%.4f", lat) + "° N"
        }
        var longFormattedString: String {
            return String(format: "%.4f", long) + "° E"
        }
        var cityStateCountry: String {
            return filterAndJoin(city, state, country)
        }
        var cityStateCountryLatLong: String {
            if lat != 0.0 && long != 0.0 {
                return filterAndJoin(city, state, country, latFormattedString, longFormattedString)
            }else{
                return manualLocation
            }
        }
        func filterAndJoin(_ locationElements: String...) -> String {
            locationElements.removeEmptiesAndJoinWith(", ")
        }
    }
    
    func config() {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        
        if isAuthorized() {
            manager?.startUpdatingLocation()
        }else{
            manager?.requestWhenInUseAuthorization()
        }
    }
    
    func isAuthorized() -> Bool {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            return true
        } else {
            return false
        }
    }
    
    func removeManager() {
        if manager != nil {
            manager?.stopUpdatingLocation()
            manager = nil
        }
    }
    
    func coordinatesToAddress(withCoordinates coordinates : CLLocationCoordinate2D, withCompletionBlock completionBlock : @escaping (_ city : String?, _ state : String?) -> ()) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            var cityBlock : String!
            var stateBlock : String!
            if let placemark = placemarks?.first {
//                if let dict = placemark.addressDictionary {
//                    if let city = dict["City"] {
//                        cityBlock = city as? String
//                    }
//                    if let state = dict["State"] {
//                        stateBlock = state as? String
//                    }
//                }
                if let postalAddress = placemark.postalAddress {
                    cityBlock = postalAddress.city
                    stateBlock = postalAddress.state
                }
            }
            completionBlock(cityBlock, stateBlock)
        }
    }

    func coordinatesToAddressWithLatLong(withCoordinates coordinates : CLLocationCoordinate2D, withCompletionBlock completionBlock : @escaping (_ location : LocationDataModel?) -> ()) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            var locationData: LocationDataModel?
            func allocateEmptyLocationDataIfNil() {
                guard locationData == nil else { return }
                locationData = LocationDataModel()
            }
            if let placemark = placemarks?.first {
                if let postalAddress = placemark.postalAddress {
                    allocateEmptyLocationDataIfNil()
                    locationData?.city = postalAddress.city
                    locationData?.state = postalAddress.state
                    locationData?.country = postalAddress.country
                }
                if let location = placemark.location {
                    allocateEmptyLocationDataIfNil()
                    locationData?.lat = Double(location.coordinate.latitude)
                    locationData?.long = Double(location.coordinate.longitude)
                }
            }
            completionBlock(locationData)
        }
    }

    func addressToCoordinatesConverter(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString("24682 Footed Ridge Ter, Sterling, VA 20166") { (placemark, error) in
            print("placemark: \(String(describing: placemark))")
            if let mark = placemark?.first {
                print("coord: \(String(describing: mark.location))")
            }
        }
    }
    
}

extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            self.delegate.locationFound(withCoordinates: lastLocation.coordinate)
            self.removeManager()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to initialize GPS: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
            // https://stackoverflow.com/questions/15153074/checking-location-service-permission-on-ios
            self.delegate.locationDenied()
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            manager.startUpdatingLocation()
        default:
            print("Warrnig : Need to see which new option added in CLAuthorizationStatus")
        }
    }
}
