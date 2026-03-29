//
//  Happy_PlantView.swift
//  Happy Plant
//
//  Created by Joshua Stapley on 5/10/22.
//  Displays live moisture readings from GATT sensor peripherals.

import SwiftUI

struct Happy_PlantView: View {
    @ObservedObject private var bleManager = Happy_PlantSensors()

    var body: some View {
        VStack(alignment: .center) {
            Text("Soil Monitor Devices")
                .font(.largeTitle)
                .padding()
            List(bleManager.deviceReadings.values.sorted(by: { $0.id < $1.id })) { reading in
                deviceDisplayData(reading: reading)
            }
        }
        .onAppear(perform: bleManager.startScanning)
        .onDisappear(perform: bleManager.stopScanning)
    }

    func deviceDisplayData(reading: Happy_PlantSensors.PlantDeviceReading) -> some View {
        let elapsedTime = Int(Date().timeIntervalSince(reading.date))
        let elapsedTimeString = createElapsedTimeString(elapsedTime: elapsedTime)
        return HStack {
            Text("Device: \(reading.id)")
            Text("Moisture Level: \(reading.moistureLevel)%")
            Text(elapsedTimeString)
        }
    }

    func createElapsedTimeString(elapsedTime: Int) -> String {
        let min  = 60
        let hour = 60 * min
        let day  = hour * 24
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
        } else {
            return "\(elapsedTime / year) y ago"
        }
    }
}

struct Happy_PlantView_Previews: PreviewProvider {
    static var previews: some View {
        Happy_PlantView()
    }
}
