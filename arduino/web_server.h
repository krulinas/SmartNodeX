#ifndef WEB_SERVER_H
#define WEB_SERVER_H

#include <WebServer.h>
#include "eeprom_utils.h"

WebServer server(80);

void setupWebHandlers();

// Launch the server and set routes
void launchWebServer() {
  setupWebHandlers();
  server.begin();
  Serial.println("Web server started");
}

// Call this regularly in loop()
void handleWebRequests() {
  server.handleClient();
}

// HTML + endpoint handlers
void setupWebHandlers() {
  server.on("/", []() {
    String content = "<html><head><style>"
                     ".button {background-color: #3CBC8D;color: white;padding: 5px 10px;cursor: pointer;}"
                     "input[type=text],[type=password] {width: 100%;padding: 5px;margin: 5px 0;background: #3CBC8D;color: white;border: none;}"
                     "body {font-family: sans-serif;}"
                     "</style></head><body>";

    content += "<h1>WiFi Manager</h1><h3>Current Settings</h3><table>";
    content += "<tr><td>SSID:</td><td>" + ssid + "</td></tr>";
    content += "<tr><td>Password:</td><td>" + pass + "</td></tr>";
    content += "<tr><td>Device ID:</td><td>" + devid + "</td></tr></table><br>";

    content += "<form method='get' action='setting'><h3>Update WiFi Settings</h3><table>";
    content += "<tr><td>SSID:</td><td><input type='text' name='ssid'></td></tr>";
    content += "<tr><td>Password:</td><td><input type='password' name='password'></td></tr>";
    content += "<tr><td>Device ID:</td><td><input type='text' name='devid'></td></tr>";
    content += "<tr><td></td><td><input class='button' type='submit' value='Save & Reboot'></td></tr>";
    content += "</table></form><br>";

    content += "<a class='button' href='/clear'>Clear EEPROM</a>";

    content += "</body></html>";

    server.send(200, "text/html", content);
  });

  server.on("/setting", []() {
    String ssidw = server.arg("ssid");
    String passw = server.arg("password");
    String devidw = server.arg("devid");
    writeCredentialsToEEPROM(ssidw, passw, devidw);
    server.send(200, "text/html", "Settings saved! Rebooting...");
    delay(2000);
    ESP.restart();
  });

  server.on("/clear", []() {
    clearEEPROM();
    server.send(200, "text/html", "EEPROM cleared! Rebooting...");
    delay(2000);
    ESP.restart();
  });
}

#endif
