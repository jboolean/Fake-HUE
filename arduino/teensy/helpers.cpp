#include "helpers.h"
#include "config.h"
#include <Arduino.h>
#include "Tlc5940.h"

/***********
 * KNOB HELPERS
 **************/
void getKnobs(unsigned int values[]){
  values[0] = analogRead(KNOB0)*4.00293;
  values[1] = analogRead(KNOB1)*4.00293;
  values[2] = analogRead(KNOB2)*4.00293;
}


/**************
 * HELPER FUNCTIONS
 ***************/
 
 //set the nth rgb led, assuming they are connected sequentially
 void setRgbLed(int n, int r, int g, int b){
   //Dioder is actually gbr
   int rPin = n * 3;
   Tlc.set(rPin, r);
   Tlc.set(rPin + 1, b);
   Tlc.set(rPin + 2, g);
 }
 
 void setHsbLed(int n, int h, int s, int b){
    int red, green, blue;
    HSBtoRGB(h, s, b, red, green, blue);
    setRgbLed(n, red, green, blue);
 }

/*all values 0-4095*/
/*from http://stackoverflow.com/questions/4123998/algorithm-to-switch-between-rgb-and-hsb-color-values*/
void HSBtoRGB(int h, int s, int v, int &red, int &green, int &blue){
  double hue = ((double)h)/11.375;
  double sat = ((double)s)/4095;
  double val = ((double)v)/4095;

  double r,g,b;

  if (sat == 0){
    r = val;
    g = val;
    b = val;
  } 
  else {
    double sectorPos = hue/60.0;
    int sectorNumber = floor(sectorPos);
    double fractionalSector = sectorPos - sectorNumber;
    double p = val * (1-sat);
    double q = val * (1- (sat * fractionalSector));
    double t = val * (1- (sat * (1 - fractionalSector)));

    switch(sectorNumber){
    case 0:
    case 6:
      r = val;
      g = t;
      b = p;
      break;
    case 1:
      r = q;
      g = val;
      b = p;
      break;
    case 2:
      r=p;
      g=val;
      b=t;
      break;
    case 3:
      r=p;
      g=q;
      b=val;
      break;
    case 4:
      r=t;
      g=p;
      b=val;
      break;
    case 5:
      r=val;
      g=p;
      b=q;
    }
  }
  red = (int)(r*4095);
  green = (int)(g*4095);
  blue = (int)(b*4095);
}

void setRgbCurrent(int r, int g, int b){
  int switchPos = getSwitch();
  if (switchPos == 5){
    for (int l = 0; l < 4; l++)
      setRgbLed(l,r,g,b);
  } else 
    setRgbLed(switchPos -1, r, g, b);
}
void setHsbCurrent(int h, int s, int b){
      int red, green, blue;
    HSBtoRGB(h, s, b, red, green, blue);
    setRgbCurrent(red, green, blue);
}
int getSwitch(){
   boolean pin1 = digitalRead(SWITCH1) == HIGH;
  boolean pin2 = digitalRead(SWITCH2) == HIGH;
  boolean pin3 = digitalRead(SWITCH3) == HIGH;
  
  if (pin1){
    if (pin2)
      return 2;
    else
      return 1;
  } else if (pin3){
    if (pin2)
      return 4;
      else
      return 5;
  }
  else 
  return 3;
}
  
  
  
  

