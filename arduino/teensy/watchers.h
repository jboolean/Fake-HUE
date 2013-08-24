/****
Call these contantly and the passed callback function will be called if something happens
***/
//will be called if the knobs were moved by a human (no noise, not precice)
void checkKnobs(void (*handler)());
//will be called when the button is first pushed down
void checkButtons(void (*buttonDownHandler)(int) );
//will be called when a full packet is read and will be passed that packet
void readPacket(void (*handler)(unsigned int[]));
