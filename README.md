# Happy_Plant
This project uses iBeacon to transmit sensor data from an ESP32 to an iPhone App called Happy Plant.
Generating the iBeacon signal is accomplished using the Arduino IDE and iBeacon libraries that have been developed for it.
The iBeacon protocol is slightly modified to send sensor data within the Major and Minor fields of the beacon.
An iPhone app was developed using Swift/SwiftUI to receive these iBeacon signals and display most recent sensor data on the screen.
The data sent is soil water content data from multiple plants.
