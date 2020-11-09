/* Modern Device Wind Sensor Sketch for Rev C Wind Sensor
  This sketch is only valid if the wind sensor if powered from
  a regulated 5 volt supply. An Arduino or Modern Device BBB, RBBB
  powered from an external power supply should work fine. Powering from
  USB will also work but will be slightly less accurate in our experience.

  When using an Arduino to power the sensor, an external power supply is better. Most Arduinos have a
  polyfuse which protects the USB line. This fuse has enough resistance to reduce the voltage
  available to around 4.7 to 4.85 volts, depending on the current draw.

  The sketch uses the on-chip temperature sensing thermistor to compensate the sensor
  for changes in ambient temperature. Because the thermistor is just configured as a
  voltage divider, the voltage will change with supply voltage. This is why the
  sketch depends upon a regulated five volt supply.

  Other calibrations could be developed for different sensor supply voltages, but would require
  gathering data for those alternate voltages, or compensating the ratio.

  Hardware Setup:
  Wind Sensor Signals    Arduino
  GND                    GND
  +V                     5V
  RV                     A1    // modify the definitions below to use other pins
  TMP                    A0    // modify the definitions below to use other pins


  Paul Badger 2014

  Hardware setup:
  Wind Sensor is powered from a regulated five volt source.
  RV pin and TMP pin are connected to analog innputs.

*/


#define analogPinForRV    1   // change to pins you the analog pins are using
#define analogPinForTMP   0
#include <string.h>

// to calibrate your sensor, put a glass over it, but the sensor should not be
// touching the desktop surface however.
// adjust the zeroWindAdjustment until your sensor reads about zero with the glass over it.

const float zeroWindAdjustment =  .2; // negative numbers yield smaller wind speeds and vice versa.

int TMP_Therm_ADunits;  //temp termistor value from wind sensor
float RV_Wind_ADunits;    //RV output from wind sensor
float RV_Wind_Volts;
unsigned long lastMillis;
int TempCtimes100;
float zeroWind_ADunits;
float zeroWind_volts;
float WindSpeed_MPH;
byte outBuffer[5];

int buzzer= 9;

void setup() {

  Serial.begin(57600);   // faster printing to get a bit better throughput on extended info
  pinMode(buzzer, OUTPUT);
}
float linMap(float in1, float in2, float out1, float out2, float inV) {
  return out1 + ((inV-in1)/(in2-in1))*(out2 - out1);
}

float clamp(float val, float lower, float upper){
  if (val> upper){
    return upper;
  }
  else if(val< lower){
    return lower;
  }
  else{
    return val;
  }
}

float bezier(float t, float a, float b, float c, float d) {
  return (1.0-t)*(1.0-t)*(1.0-t)*a +
         3.0*(1.0-t)*(1.0-t)*t*b +
         3.0*(1.0-t)*t*t*c +
         t*t*t * d;
}
void loop() {


  //  if (millis() - lastMillis > 200){      // read every 200 ms - printing slows this down further

  TMP_Therm_ADunits = analogRead(analogPinForTMP);
  RV_Wind_ADunits = analogRead(analogPinForRV);
  RV_Wind_Volts = (RV_Wind_ADunits *  0.0048828125);

  // these are all derived from regressions from raw data as such they depend on a lot of experimental factors
  // such as accuracy of temp sensors, and voltage at the actual wind sensor, (wire losses) which were unaccouted for.
  TempCtimes100 = (0.005 * ((float)TMP_Therm_ADunits * (float)TMP_Therm_ADunits)) - (16.862 * (float)TMP_Therm_ADunits) + 9075.4;

  zeroWind_ADunits = -0.0006 * ((float)TMP_Therm_ADunits * (float)TMP_Therm_ADunits) + 1.0727 * (float)TMP_Therm_ADunits + 47.172; //  13.0C  553  482.39

  zeroWind_volts = (zeroWind_ADunits * 0.0048828125) - zeroWindAdjustment;


  WindSpeed_MPH =  pow(((RV_Wind_Volts - zeroWind_volts) / .2300) , 2.7265);
  outBuffer[0] = 128;


  if (WindSpeed_MPH != WindSpeed_MPH) {
    WindSpeed_MPH = 0;

  }
  
  int interval = 100;
  int w = millis()% interval;
  float frac = linMap(0.0, 40.0, 0.0, 1.0, WindSpeed_MPH);
  frac = 1.0 - clamp((bezier(frac, 1.0, 0.1, 0.2, 0.0)), 0.0, 1.0);
  float freq = 1.0 - frac;
  int band = w < interval * freq ? 0 : 1;
  digitalWrite(buzzer, band);


  memcpy(outBuffer + 1, &WindSpeed_MPH, sizeof(float));

  Serial.write (outBuffer, 5);



}
