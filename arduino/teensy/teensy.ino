#define RED 0
#define GREEN 1
#define BLUE 2
#define PACKETLENGTH 8
void setup(){
  // initialize serial:
  Serial.begin(9600);
}
void loop(){
  readPacket();
}

/*
 Occurs when a complete packet is available
 readPacket() must be called as often as possible for this event to occur
*/
void handlePacketReceived(unsigned int data[3]){
   Serial.print("R: ");  
    Serial.println(data[RED], DEC);
    Serial.print("G: ");
    Serial.println(data[GREEN], DEC);
    Serial.print("B: ");
    Serial.println(data[BLUE], DEC);
    Serial.println("---------------");
}



/********
PACKET READING STUFF
********/
//the incoming data packet
unsigned int data[3];

//trigger every time data are available
int pos = 4;//pos in data, reset to 0 when header read
int last = 0;//last possible header bit read
boolean firstBitRead = false;//reading the first or second bit of data?
//read a packet into the data array
/*
Packet protocol
255 255 (RR) (GG) (BB)
That's 2 bytes of 1s as the header, followed by 3 2-bit ints for the color
*/
void readPacket(){
  if (!Serial.available())
    return;
  int thisByte = Serial.read();//only read ONCE per loop
  //read some real data
  if (pos < 3){
    if (!firstBitRead){
      data[pos] =thisByte << 8;
      firstBitRead = true;
    } 
    else {
      data[pos] |= thisByte;
      if (pos == 2){
        handlePacketReceived(data);
      }
      pos++;
      firstBitRead = false;
    }
  } 
  else {//read all the data, we need a header
    int cur = thisByte;
    if (last == 0xFF && thisByte == 0xFF){
      pos = 0;
      last = 0;//trash var to prepare for next header
      for (int i = 0; i< 3; i++)//zero out data
        data[i] = 0;
    } 
    else
      last = thisByte;
  }

  delay(1);
}








