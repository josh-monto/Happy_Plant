//
//  Happy_PlantBase.swift
//  Happy Plant
//
//  Created by Joshua Stapley on 5/10/22.
//  Templated from ibeaconExample by Oleg Simonov and Elijah Allen. https://github.com/eaallen/ibeaconExample
//  Lightly modified for this application.

import Foundation
import CoreLocation
 
class Happy_PlantBase: NSObject, ObservableObject, CLLocationManagerDelegate {
    //location access is required for iBeacon use
    var locationManager: CLLocationManager?
    override init(){
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // for requesting location access
        locationManager?.requestWhenInUseAuthorization()
    }
    
    //check to make sure location permissions have been authorized...if not, print notification to console
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {return Happy_PlantBase.beaconsWereNotGivenPermission()}
            guard CLLocationManager.isRangingAvailable() else {return Happy_PlantBase.beaconsWereNotGivenPermission()}
        }else {
            Happy_PlantBase.beaconsWereNotGivenPermission()
        }
    }
    
    //check to see if ranging has been successful
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    }
    
    private static func beaconsWereNotGivenPermission(){
        // prints to console when permissions haven't been accepted
        print("beacons not given permission!")
    }
 
    
}

