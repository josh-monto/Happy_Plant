/*
   ESP32 GATT Peripheral for Happy Plant soil moisture monitoring.
   Exposes a custom BLE service with a moisture level characteristic.
   The iOS app connects and reads/subscribes to the characteristic.

   Based on original iBeacon implementation by Joshua Stapley.
   Migrated to GATT by Joshua Stapley.
*/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLECharacteristic.h>
#include <BLE2902.h>
#include <esp_sleep.h>
#include <map>

#define SLEEP_DURATION      5     // seconds to sleep between readings
#define ADVERTISE_DURATION  2000  // ms to advertise before sleeping if no connection
#define CONNECTED_TIMEOUT   5000  // additional ms to wait after a connection

#define DEVICE_ID           4     // unique integer per device (0-5)

#define SERVICE_UUID        "46459ef7-4f2a-984e-4e98-2a4ff79e4546"
#define MOISTURE_CHAR_UUID  "46459ef7-4f2a-984e-4e98-2a4ff79e4547"

// Maps raw sensor values to moisture percentage (0-100%)
std::map<int, int> calibrationData {
  {10000, 0}, {3253, 0}, {3252, 2}, {3251, 4}, {3250, 6}, {3240, 8},
  {3230, 10}, {3220, 12}, {3210, 14}, {3180, 16}, {3150, 18}, {3120, 20},
  {3090, 22}, {3060, 24}, {3030, 26}, {3005, 28}, {2980, 30}, {2940, 32},
  {2900, 34}, {2850, 36}, {2800, 38}, {2755, 40}, {2710, 42}, {2680, 44},
  {2650, 46}, {2615, 48}, {2580, 50}, {2545, 52}, {2510, 54}, {2490, 56},
  {2470, 58}, {2445, 60}, {2420, 62}, {2395, 64}, {2370, 66}, {2350, 68},
  {2330, 70}, {2310, 72}, {2290, 74}, {2280, 76}, {2270, 78}, {2260, 80},
  {2250, 82}, {2240, 84}, {2230, 86}, {2225, 88}, {2220, 90}, {2215, 92},
  {2210, 94}, {2205, 96}, {2200, 98}, {2199, 100}, {0, 100}
};

bool deviceConnected = false;

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
  }
  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
  }
};

void setup() {
  Serial.begin(115200);

  // Read and calibrate sensor
  std::map<int, int>::iterator sensorData = calibrationData.lower_bound(analogRead(15));
  uint8_t moistureLevel = (uint8_t)sensorData->second;
  Serial.print("Moisture Level: ");
  Serial.println(moistureLevel);

  // Initialize BLE with a unique device name
  String deviceName = "HappyPlant_" + String(DEVICE_ID);
  BLEDevice::init(deviceName.c_str());

  // Set up GATT server
  BLEServer* pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  // Create service and moisture characteristic
  BLEService* pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic* pMoistureChar = pService->createCharacteristic(
    MOISTURE_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  pMoistureChar->addDescriptor(new BLE2902());
  pMoistureChar->setValue(&moistureLevel, 1);
  pService->start();

  // Advertise the service UUID so the iOS app can discover this device
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->start();
  Serial.println("Advertising started...");

  // Wait for advertising window; extend if a client connects
  unsigned long startTime = millis();
  while (millis() - startTime < ADVERTISE_DURATION ||
         (deviceConnected && millis() - startTime < ADVERTISE_DURATION + CONNECTED_TIMEOUT)) {
    delay(10);
  }

  pAdvertising->stop();
  Serial.println("Entering deep sleep...");
  esp_deep_sleep(1000000LL * SLEEP_DURATION);
}

void loop() {
}
