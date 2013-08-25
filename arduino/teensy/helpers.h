#ifndef HELPERS_H
#define HELPERS_H
void getKnobs(unsigned int values[]);
void setRgbCurrent(int r, int g, int b);
void setRgbLed(int n, int r, int g, int b);
void setRgbLedWithFade(int n, int timeMillis, int r, int g, int b);
void setHsbCurrent(int h, int s, int b);
void setHsbLed(int n, int h, int s, int b);
void HSBtoRGB(int h, int s, int v, int &red, int &green, int &blue);
int getSwitch();
#endif

