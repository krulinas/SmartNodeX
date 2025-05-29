#ifndef WIFI_UTILS_H
#define WIFI_UTILS_H

#include <WiFi.h>

extern String ssid, pass;
bool apModeActive = false;

void launchWebServer();  // Forward declaration

// Attempt to connect to stored WiFi
bool connectToWiFi() {
  WiFi.softAPdisconnect(true);
  WiFi.disconnect(true);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid.c_str(), pass.c_str());

  Serial.println("Connecting to WiFi...");
  for (int i = 0; i < 50; i++) {
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("WiFi connected!");
      Serial.println(WiFi.localIP());
      WiFi.setAutoReconnect(true);
      WiFi.persistent(true);
      return true;
    }
    Serial.print(".");
    delay(500);
  }

  Serial.println("\nWiFi connection failed.");
  return false;
}

// Launch Access Point mode if no WiFi
void startAccessPointMode() {
  const char* ssidap = "ESP32_2025";
  const char* passap = "";
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssidap, passap);

  Serial.println("AP Mode active. Connect to: " + WiFi.softAPIP().toString());
  apModeActive = true;
  launchWebServer();
}

// Check current mode
bool isInAPMode() {
  return apModeActive;
}

#endif
