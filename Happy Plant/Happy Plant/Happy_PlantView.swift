//
//  Happy_PlantView.swift
//  Happy Plant
//
//  Created by Joshua Stapley on 5/10/22.
//  Templated off of ibeaconExample by Oleg Simonov and Elijah Allen. https://github.com/eaallen/ibeaconExample
//  Modified for this application.

import SwiftUI
 
struct Happy_PlantView: View {
    // the hard coded UUID should be unique to our business. We will need to make sure that all of our ibeacons have the same uuid
    let beaconUUID = UUID(uuidString: "46459ef7-4f2a-984e-4e98-2a4ff79e4546")!
    @ObservedObject private var beaconDetector = Happy_PlantBeacons()
    var body: some View {
        //main view screen
        VStack(alignment: .center){
            //title
            Text("Soil Monitor Devices")
                .font(.largeTitle)
                .padding()
            //beacon objects listed in app, calls function for data display
            List(beaconDetector.beaconInfo["0"] ?? []){ item in
                beaconDisplayData(item: item)
            }
            List(beaconDetector.beaconInfo["1"] ?? []){ item in
                beaconDisplayData(item: item)
            }
            List(beaconDetector.beaconInfo["2"] ?? []){ item in
                beaconDisplayData(item: item)
            }
            List(beaconDetector.beaconInfo["3"] ?? []){ item in
                beaconDisplayData(item: item)
            }
            List(beaconDetector.beaconInfo["4"] ?? []){ item in
                beaconDisplayData(item: item)
            }
            List(beaconDetector.beaconInfo["5"] ?? []){ item in
                beaconDisplayData(item: item)
            }
        }
        //beacon scan will be performed while this screen is in view
        .onAppear(perform: startScanning)
        .onDisappear(perform: stopScanning)
    }
    
    //function called for displaying beacon data in app
    func beaconDisplayData(item: Happy_PlantBeacons.BeaconHistoryItem) -> some View {
        //elapsed time from last time sensor update was successfully received, in seconds
        let elapsedTime = Int(Date().timeIntervalSince(item.date))
        //elapsed time string to be displayed in app
        let elapsedTimeString = createElapsedTimeString(elapsedTime: elapsedTime)
        print(item)
        return  HStack {
            Text("Device: \(item.beacon.major)")
            Text("Moisture Level: \(item.beacon.minor)%")
            Text("\(elapsedTimeString)")
        }
    }
    
    //scan starts on beacons with given uuid
    func startScanning(){
        beaconDetector.startScanning(beaconUUID: beaconUUID )
    }
    //stop scan on given beacons
    func stopScanning(){
        beaconDetector.stopScanning(beaconUUID: beaconUUID)
    }
    //create string that will be printed for elapsed time since last update of sensor data
    func createElapsedTimeString(elapsedTime: Int) -> String {
        let min = 60
        let hour = 60 * min
        let day = hour * 24
        let week = day * 7
        let year = day * 365
        
        if elapsedTime < min {
            return "\(elapsedTime) s ago"
        } else if elapsedTime < hour {
            return "\(elapsedTime / min) m ago"
        } else if elapsedTime < day {
            return "\(elapsedTime / hour) h ago"
        } else if elapsedTime < week {
            return "\(elapsedTime / day) d ago"
        } else if elapsedTime < year {
            return "\(elapsedTime / week) w ago"
        } else if elapsedTime > year {
            return "\(elapsedTime / year) y ago"
        } else {
            return "ago"
        }
    }
}
 
struct Happy_PlantView_Previews: PreviewProvider {
    static var previews: some View {
        Happy_PlantView()
    }
}
