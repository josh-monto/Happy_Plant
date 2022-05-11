//
//  Happy_PlantBeacons.swift
//  Happy Plant
//
//  Created by Joshua Stapley on 5/10/22.
//  Templated from ibeaconExample by Oleg Simonov and Elijah Allen. https://github.com/eaallen/ibeaconExample
//  Lightly modified for this application.

import Foundation
import CoreLocation
import SwiftUI
 
class Happy_PlantBeacons: Happy_PlantBase {
    @Published var currentBeacon : CLBeacon? = nil
    @Published var beaconInfo : [
        String : [BeaconHistoryItem]
    ] = [:]
    override init(){
        super.init()
    }
    //CLLocationManager needs to be used to range the beacons, as sharing proximity information is the intended use of iBeacon, though this protocol is modified slightly to share sensor data instead
    override func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons)
        } else {
            
        }
    }
    
    //Updates beacon info for device whenever a signal is received
    func updateDistance(_ beacons: [CLBeacon]) {
        currentBeacon = beacons[0]
        // ensure we only add a value to the history list if there has been a change in rssi
        for beacon in beacons{
            beaconInfo["\(beacon.major)"] = [BeaconHistoryItem(beacon: beacon)]
        }
    }
    
    //we need to start monitoring the ibeacons. Ranging is required to grab data from major and minor fields (which contain info specific to each sensor)
    func startScanning(beaconUUID: UUID) {
        let beaconRegion = CLBeaconRegion()
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: .init(uuid: beaconUUID))
    }
    
    func stopScanning(beaconUUID: UUID){
        let beaconRegion = CLBeaconRegion()
        locationManager?.stopMonitoring(for: beaconRegion)
        locationManager?.stopRangingBeacons(satisfying: .init(uuid: beaconUUID))
    }
    
    //most recent history of data from ibeacon is stored in this structure. CLBeacon contains all fields of the ibeacon. Date is used for calculating elapsed time since last update.
    struct BeaconHistoryItem : Identifiable {
        var id = UUID()
        var beacon: CLBeacon
        var date = Date()
    }
}

