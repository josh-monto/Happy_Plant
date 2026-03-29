//
//  Happy_PlantBase.swift
//  Happy Plant
//
//  Created by Joshua Stapley on 5/10/22.
//  Uses CoreBluetooth as the base for BLE central management.

import Foundation
import CoreBluetooth

class Happy_PlantBase: NSObject, ObservableObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // subclasses override to respond to BLE state changes
    }
}
