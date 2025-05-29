#ifndef EEPROM_UTILS_H
#define EEPROM_UTILS_H

#include <EEPROM.h>

// Stores user-defined WiFi credentials and Device ID
String ssid = "";
String pass = "";
String devid = "";

// Clears entire EEPROM
void clearEEPROM() {
  EEPROM.begin(512);
  for (int i = 0; i < 512; i++) EEPROM.write(i, 0);
  EEPROM.commit();
  EEPROM.end();
  Serial.println("EEPROM cleared");
}

// Reads WiFi SSID, password, and device ID from EEPROM
void readCredentialsFromEEPROM() {
  EEPROM.begin(512);
  Serial.println("Reading EEPROM...");

  ssid = "";
  pass = "";
  devid = "";

  for (int i = 0; i < 20; i++) {
    char c = char(EEPROM.read(i));
    if (c != 0) ssid += c;
  }
  for (int i = 20; i < 40; i++) {
    char c = char(EEPROM.read(i));
    if (c != 0) pass += c;
  }
  for (int i = 40; i < 60; i++) {
    char c = char(EEPROM.read(i));
    if (c != 0) devid += c;
  }

  Serial.println("SSID: " + ssid);
  Serial.println("PASS: " + pass);
  Serial.println("DEVID: " + devid);
  EEPROM.end();
}

// Writes WiFi SSID, password, and device ID to EEPROM
void writeCredentialsToEEPROM(String a, String b, String c) {
  clearEEPROM();
  EEPROM.begin(512);
  Serial.println("Writing to EEPROM...");

  for (int i = 0; i < a.length(); i++) EEPROM.write(i, a[i]);
  EEPROM.write(a.length(), 0);

  for (int i = 0; i < b.length(); i++) EEPROM.write(20 + i, b[i]);
  EEPROM.write(20 + b.length(), 0);

  for (int i = 0; i < c.length(); i++) EEPROM.write(40 + i, c[i]);
  EEPROM.write(40 + c.length(), 0);

  EEPROM.commit();
  EEPROM.end();
  Serial.println("Write successful");
}

#endif
