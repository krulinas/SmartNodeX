#include "wifi_utils.h"
#include "display_utils.h"
#include "eeprom_utils.h"
#include "web_server.h"
#include "dht_utils.h"
#include <HTTPClient.h>

static bool blinkOn = false;
static unsigned long lastBlink = 0;
static unsigned long lastUpdate = 0;

const char* backend_url = "https://tensorflowtitan.xyz/backend/insert.php";

void setup() {
  Serial.begin(115200);
  initDisplay();
  initDHT();
  readCredentialsFromEEPROM();

  showStartupScreen();

  if (connectToWiFi()) {
    showWiFiSuccessScreen();
  } else {
    startAccessPointMode();
    showAPModeScreen();
  }
}

void postSensorData(float temp, float hum) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(backend_url);
    http.addHeader("Content-Type", "application/json");

    String payload = "{\"temperature\":" + String(temp) + ",\"humidity\":" + String(hum) + "}";
    int httpResponseCode = http.POST(payload);

    Serial.print("POST Response Code: ");
    Serial.println(httpResponseCode);
    http.end();
  } else {
    Serial.println("WiFi not connected. Cannot send data.");
  }
}

void loop() {
  handleWebRequests(); // For AP mode config

  // Read + send every 10s
  if (millis() - lastUpdate > 10000) {
    lastUpdate = millis();

    float temp = readTemperature();
    float hum = readHumidity();
    checkAndTriggerRelay(temp, hum);
    postSensorData(temp, hum);
  }

  // Blink OLED status every 1s
  if (millis() - lastBlink > 1000) {
    lastBlink = millis();
    blinkOn = !blinkOn;

    float temp = readTemperature();
    float hum = readHumidity();
    bool relayActive = digitalRead(RELAY_PIN);

    String line1 = "Temp: " + String(temp) + " C";
    String line2 = "Hum: " + String(hum) + " %";
    String line3 = relayActive ? (blinkOn ? "Relay Activated" : "") : "Relay Offline";
    String line4 = (temp > TEMP_THRESHOLD || hum > HUMIDITY_THRESHOLD) ? "ALERT!" : "Normal";


    updateDisplay(line1, line2, line3, line4);
  }
}
