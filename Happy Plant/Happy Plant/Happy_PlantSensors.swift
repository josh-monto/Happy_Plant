//
//  Happy_PlantSensors.swift
//  Happy Plant
//
//  Created by Joshua Stapley on 5/10/22.
//  Uses CoreBluetooth/GATT to connect to plant moisture sensor peripherals.

import Foundation
import CoreBluetooth

class Happy_PlantSensors: Happy_PlantBase, CBPeripheralDelegate {
    @Published var deviceReadings: [String: PlantDeviceReading] = [:]

    private var discoveredPeripherals: [CBPeripheral] = []

    static let serviceUUID     = CBUUID(string: "46459ef7-4f2a-984e-4e98-2a4ff79e4546")
    static let moistureCharUUID = CBUUID(string: "46459ef7-4f2a-984e-4e98-2a4ff79e4547")

    override init() {
        super.init()
    }

    // MARK: - Scanning

    func startScanning() {
        guard centralManager?.state == .poweredOn else { return }
        centralManager?.scanForPeripherals(
            withServices: [Happy_PlantSensors.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    func stopScanning() {
        centralManager?.stopScan()
        for peripheral in discoveredPeripherals {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        discoveredPeripherals.removeAll()
    }

    // MARK: - CBCentralManagerDelegate

    override func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard !discoveredPeripherals.contains(peripheral) else { return }
        discoveredPeripherals.append(peripheral)
        central.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([Happy_PlantSensors.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        discoveredPeripherals.removeAll { $0 == peripheral }
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([Happy_PlantSensors.moistureCharUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.uuid == Happy_PlantSensors.moistureCharUUID {
            peripheral.readValue(for: characteristic)
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard characteristic.uuid == Happy_PlantSensors.moistureCharUUID,
              let data = characteristic.value,
              let deviceName = peripheral.name else { return }

        let moistureLevel = Int(data[0])
        DispatchQueue.main.async {
            self.deviceReadings[deviceName] = PlantDeviceReading(
                id: deviceName,
                moistureLevel: moistureLevel,
                date: Date()
            )
        }
    }

    // MARK: - Data Model

    struct PlantDeviceReading: Identifiable {
        var id: String
        var moistureLevel: Int
        var date: Date
    }
}
