/*
   Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleScan.cpp
   Ported to Arduino ESP32 by pcbreflux
   Modified by Joshua Stapley for Happy Plant iBeacon
*/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLEBeacon.h>
#include <esp_sleep.h>
#include <map>

#define SLEEP_DURATION     5  // sleep x seconds and then wake up

int moistureLevel;

BLEAdvertising *pAdvertising;

#define BEACON_UUID           "46459ef7-4f2a-984e-4e98-2a4ff79e4546" // UUID

//this maps the sensor read value to an accurate moisture level between 0 and 100%
std::map <int, int> calibrationData { {10000 , 0}, {3253 , 0}, {3252 , 2}, {3251 , 4}, {3250 , 6}, {3240 , 8}, 
{3230 , 10}, {3220 , 12}, {3210 , 14}, {3180 , 16}, {3150 , 18}, {3120 , 20}, {3090 , 22}, 
{3060 , 24}, {3030 , 26}, {3005 , 28}, {2980 , 30}, {2940 , 32}, {2900 , 34}, {2850 , 36}, 
{2800 , 38}, {2755 , 40}, {2710 , 42}, {2680 , 44}, {2650 , 46}, {2615 , 48}, {2580 , 50}, 
{2545 , 52}, {2510 , 54}, {2490 , 56}, {2470 , 58}, {2445 , 60}, {2420 , 62}, {2395 , 64}, 
{2370 , 66}, {2350 , 68}, {2330 , 70}, {2310 , 72}, {2290 , 74}, {2280 , 76}, {2270 , 78}, 
{2260 , 80}, {2250 , 82}, {2240 , 84}, {2230 , 86}, {2225 , 88}, {2220 , 90}, {2215 , 92}, 
{2210 , 94}, {2205 , 96}, {2200 , 98}, {2199 , 100}, {0 , 100} };

void setup() {
  Serial.begin(115200);

  std::map <int, int>::iterator sensorData = calibrationData.lower_bound(analogRead(15));
  moistureLevel = sensorData->second;
  Serial.print("Moisture Level: ");
  Serial.println(moistureLevel);
  
  // Create the BLE Device
  BLEDevice::init("happyPlantBeacon");
  BLEServer *pServer = BLEDevice::createServer();
 
  BLEBeacon myBeacon;
  myBeacon.setManufacturerId(0x4c00); //fake manufacturer id
  //The UUID gets flipped when setting directly with myBeacon.setProximityUUID(BLEUUID(BEACON_UUID))
  //The next 3 lines set it correctly. Each ESP32 for the project will have the same UUID
  BLEUUID bleUUID = BLEUUID(BEACON_UUID);
  bleUUID = bleUUID.to128();
  myBeacon.setProximityUUID(BLEUUID(bleUUID.getNative()->uuid.uuid128, 16, true));
  //the Major field contains a unique identifier, will set it to a different # for each individual ESP32
  myBeacon.setMajor(4);
  //the Minor field contains updated sensor output
  myBeacon.setMinor(moistureLevel);
  myBeacon.setSignalPower(0xc5);
 
  BLEAdvertisementData advertisementData;
  advertisementData.setFlags(0x1A);
  advertisementData.setManufacturerData(myBeacon.getData());
 
  BLEAdvertising* pAdvertising = pServer->getAdvertising();
  pAdvertising->setAdvertisementData(advertisementData);
  pAdvertising->start();
  Serial.println("Advertising started...");
  delay(50);
  pAdvertising->stop();
  Serial.printf("enter deep sleep\n");
  esp_deep_sleep(1000000LL * SLEEP_DURATION);
}

void loop() {
}
