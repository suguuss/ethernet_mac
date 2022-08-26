from scapy.all import *
from threading import Thread
from time import sleep


MAC_DST			= "00:11:22:33:44:55"
INTERFACE_ID 	= 3
SEND_COUNT			= 1


def send():
	# List available interfaces
	# print(conf.ifaces)

	sleep(0.1)

	# Create the packet
	p = Ether(dst=MAC_DST, type=0) / ("ABCE"*25)

	print(f"sending packet : ")
	p.show()

	# Send the packet
	# WINDOWS : 
	sendp(p, iface=conf.ifaces.dev_from_index(INTERFACE_ID), count=SEND_COUNT)
	# LINUX 
	# sendp(p, iface="eth0", count=SEND_COUNT)


def main():
	Thread(target=send).start()

	cap = sniff(iface=conf.ifaces.dev_from_index(INTERFACE_ID), 
				filter=f"ether src {MAC_DST}", 
				count=SEND_COUNT)

	packet = cap[0]

	print("\nPacket captured : ")
	packet.show()

if __name__ == '__main__':
	main()