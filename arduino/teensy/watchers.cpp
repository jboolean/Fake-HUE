#include "watchers.h"
#include "config.h"
#include <Arduino.h>


//Call frequently to watch knobs for significant change.
int lastSigKnobValues[3];
#define SIGNIFICANT_CHANGE 70
void checkKnobs(void (*callback)()){
  int values[3];
  values[0] = analogRead(KNOB0);
  values[1] = analogRead(KNOB1);
  values[2] = analogRead(KNOB2);
  //getKnobs(values);
  for (int i = 0; i < 3; i++){
    if (abs((int)values[i]-(int)lastSigKnobValues[i]) > SIGNIFICANT_CHANGE){
      for (int k =0; k<3;k++)
        lastSigKnobValues[k]=values[k];
      (*callback)();
      return;
    }
  }
}


//button watchers
boolean lastCycleButton = false;
void checkButtons(void (*handler)(int) ){
  boolean cycleButton = digitalRead(CYCLE_BUTTON) == HIGH;
  if (cycleButton != lastCycleButton && cycleButton)
    (*handler)(CYCLE_BUTTON);  
  lastCycleButton = cycleButton;
}


/********
 * PACKET READING STUFF
 ********/
//the incoming data packet
unsigned int data[DATA_LENGTH];

//trigger every time data are available
int pos = DATA_LENGTH;//pos in data, reset to 0 when header read
int last = 0;//last possible header bit read
boolean firstBitRead = false;//reading the first or second bit of data?
//read a packet into the data array
/*
Packet protocol
 255 255 (Lamp#) (Time / 100ms) (RR) (GG) (BB)
 That's 2 bytes of 1s as the header, followed by 3 2-bit ints for the color
 */
void readPacket(void (*handler)(unsigned int[])){
  if (!Serial.available())
    return;
  int thisByte = Serial.read();//only read ONCE per loop
  //read some real data
  if (pos < DATA_LENGTH){
    if (pos == LAMP || pos == TIME){//the lamp and time positions are one byte
      data[pos++]=(int)thisByte;
    } 
    else {
      if (!firstBitRead){
        data[pos] =thisByte << 8;
        firstBitRead = true;
      } 
      else {
        data[pos] |= thisByte;
        if (pos == DATA_LENGTH - 1){
          (*handler)(data);
        }
        pos++;
        firstBitRead = false;
      }
    }
  } 
  else {//read all the data, we need a header
    int cur = thisByte;
    if (last == 0xFF && thisByte == 0xFF){
      pos = 0;
      last = 0;//trash var to prepare for next header
      for (int i = 0; i< DATA_LENGTH; i++)//zero out data
        data[i] = 0;
    } 
    else
      last = thisByte;
  }

  delay(1);
}






