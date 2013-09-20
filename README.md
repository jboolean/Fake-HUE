This is a server that mimics the Philips HUE api and talks to my IKEA Dioder lights through a circuit containing the Arduino-like Teensy, allowing the lights to be controlled through numerous mobile apps written for the HUE platform.

*This is a personal project not for distribution or use for anyone but myself. The HUE bulbs are much better. I will not provide circuit schematics. *

The server is written in Ruby with Sinatra and runs on a Raspberry Pi. It is connected to the Teensy over USB. A custom protocol was written to pass red, green, blue, and fade values.

The custom circuit board replaces the out-of-the-box IKEA Dioder controller.
The Teensy drives a TLC5940 PWM controller. Each light strip plugs into the board individually, allowing separate control of each strip as a "bulb" in the API. The IKEA Dioder power adapter also plugs into the board to provide power to the lights and the Teensy.

Additionally, the lights can be controlled via knobs and switches in case the RasPi is not connected.
