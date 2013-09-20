#include "Tlc5940.h"
#include "tlc_fades.h"
#include <math.h>
#include "helpers.h"
#include "watchers.h"
#include "config.h"



byte mode = FADE_CYCLE;
void setup(){
  // initialize serial:
  Serial.begin(9600);
  Tlc.init();
  pinMode(KNOB0, INPUT);
  pinMode(KNOB1, INPUT);
  pinMode(KNOB2, INPUT);
  pinMode(CYCLE_BUTTON, INPUT);
  pinMode(SWITCH1, INPUT);
  pinMode(SWITCH2, INPUT);
  pinMode(SWITCH3, INPUT);
}
void loop(){
  switch(mode){
  case HSB_KNOBS:
    HSBLoop();
    break;
  case FADE_CYCLE:
    fadeCycleLoop();
    break;
  }

  readPacket(handlePacketReceived);//checks for serial data and reads it
  checkKnobs(handleKnobsChangedSignificantly);//checks knobs for significant changes
  checkButtons(handleButtonPress);
  Tlc.update();
  tlc_updateFades();
}
/***********
 * Mode loops
 ************/
void HSBLoop(){
  unsigned int values[3];
  getKnobs(values);
  setHsbCurrent(values[0], values[1], values[2]);

}

int cycleH =0;
void fadeCycleLoop(){
  for (int l = 0; l < 4; l++)
    setHsbLed(l, cycleH, 4095, 4095);
  if (++cycleH > 4095)
    cycleH = 0;
  delay(4);
}


/***********
 * EVENT HANDLERS
 ***********/
int lastR[4];
int lastG[4];
int lastB[4];
/*
 Occurs when a complete packet is available
 readPacket() must be called as often as possible for this event to occur
 */
void handlePacketReceived(unsigned int data[DATA_LENGTH]){
  mode = SERIAL_CONTROL;
  
  Serial.print("R: ");  
   Serial.println(data[RED], DEC);
   Serial.print("G: ");
   Serial.println(data[GREEN], DEC);
   Serial.print("B: ");
   Serial.println(data[BLUE], DEC);
   Serial.println("---------------");
  int rPin = data[LAMP] *3;
  uint32_t nowMillis = millis();
  tlc_addFade(rPin + 0, lastR[data[LAMP]], data[RED], nowMillis, nowMillis+data[TIME]*100);
  tlc_addFade(rPin + 1, lastB[data[LAMP]], data[BLUE], nowMillis, nowMillis+data[TIME]*100);
  tlc_addFade(rPin + 2, lastG[data[LAMP]], data[GREEN], nowMillis, nowMillis+data[TIME]*100);
  lastR[data[LAMP]] = data[RED];
  lastG[data[LAMP]] = data[GREEN];
  lastB[data[LAMP]] = data[BLUE];
  //setRgbLedWithFade(data[LAMP],data[TIME]*100, data[RED], data[GREEN], data[BLUE]);
}

/*
Called when knobs were definitely moved by someone, not noise
 */
void handleKnobsChangedSignificantly(){
  mode = HSB_KNOBS;
}

/*
Callen when a button is pressed down
 */
void handleButtonPress(int buttonId){
  if (buttonId == CYCLE_BUTTON){
    mode = FADE_CYCLE;
  }
}








