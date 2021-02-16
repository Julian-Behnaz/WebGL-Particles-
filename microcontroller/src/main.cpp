// Variable resistance stretch cord testing code! Made Jan 29 by Erin Gee for Instructables
#include <Arduino.h>
int sensorPin = 14;    // select the input pin for the potentiometer
int ledPin = 9;      // select the pin for the LED
int sensorValue = 0;  // variable to store the value coming from the sensor
int fadeValue = 0;
int scaleValue = 4;  //This scales the input into something the LED can handle

uint8_t send_buffer[5];

void setup() {
  // declare the ledPin as an OUTPUT:
  pinMode(ledPin, OUTPUT);
  // initialize serial communications at 9600 bps:
  Serial.begin(115200);
}

void loop() {
  
  send_buffer[0] = 128;
  uint32_t* val = ((uint32_t*)(send_buffer+1));
  *val = analogRead(sensorPin);
  Serial.write(send_buffer, 5);

  // // read the value from the sensor:
  // sensorValue = analogRead(sensorPin);
  // // divide it into a value from 0-255
  // fadeValue = sensorValue/scaleValue;
  // //write these values to Serial Window
  // Serial.write(fadeValue);
  // //write to LED 
  // analogWrite(ledPin, fadeValue);
  delay(5);
}


// 2^7 == 128   127
// 2^8 == 256   255

// int8_t  uint8_t
