#ifndef DHT_UTILS_H
#define DHT_UTILS_H

#include <DHT.h>

#define DHTPIN 4         // GPIO where DHT11 is connected
#define DHTTYPE DHT11    // DHT 11
#define RELAY_PIN 26     // Updated to your relay pin (D26)

#define TEMP_THRESHOLD 35.0
#define HUMIDITY_THRESHOLD 97.0

DHT dht(DHTPIN, DHTTYPE);

// Initialize DHT sensor and relay pin
void initDHT() {
  dht.begin();
  pinMode(RELAY_PIN, OUTPUT);
  Serial.println("DHT11 & Relay initialized");
}

// Read temperature in Celsius
float readTemperature() {
  return dht.readTemperature();
}

// Read humidity in percentage
float readHumidity() {
  return dht.readHumidity();
}

// Check threshold and activate relay if needed
bool checkAndTriggerRelay(float temp, float hum) {
  bool trigger = temp > TEMP_THRESHOLD || hum > HUMIDITY_THRESHOLD;
  digitalWrite(RELAY_PIN, trigger ? HIGH : LOW);  // Relay ON if HIGH (check if yours is active HIGH or LOW)
  return trigger;
}

// Return "ON" or "OFF" for relay status
String relayStatusString() {
  return digitalRead(RELAY_PIN) ? "ON" : "OFF";
}

#endif
