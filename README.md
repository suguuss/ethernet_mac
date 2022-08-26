# Ethernet Module

A small ethernet module that can send and receive raw ethernet packets (UDP might work with some small modifications) with a fixed data length.

Tested on a MAX10 (Arrow DECA development board)

## ethernet_top

The design in the top level is a loopback. What is sent to the FPGA will be sent back to the computer.

You can test it by using the `send.py` script : 

```Py
> python send.py

sending packet : 
###[ Ethernet ]###
  dst       = 00:11:22:33:44:55
  src       = 00:d8:61:19:49:3b
  type      = 0x0
###[ Raw ]###
	load      = 'ABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCE'     

.
Sent 1 packets.

Packet captured :
###[ 802.3 ]###
  dst       = 00:d8:61:19:49:3b
  src       = 00:11:22:33:44:55
  len       = 0
###[ Padding ]###
	load      = 'ABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCEABCE' 
```

or by sending a packet and checking the response in wireshark.

