ETHERNET=ethernet
ETHERNET_TX=ethernet_tx
ETHERNET_RX=ethernet_rx
CRC=crc_gen
TXFIFO=tx_fifo
RXFIFO=rx_fifo

UUT=$(ETHERNET)

SRC=src
TB=tb

GHDL=ghdl
GHDLFLAGS=
GHDLRUNFLAGS=

# Default target : elaborate
all : init elab

# Elaborate target.  Almost useless
elab : force
	# $(GHDL) -c $(GHDLFLAGS) -e $(ETHERNET)
	# $(GHDL) -c $(GHDLFLAGS) -e $(CRC)

# Run target
run : force
	# $(GHDL) -c $(GHDLFLAGS) -r $(SRC)/$(ETHERNET) $(GHDLRUNFLAGS)
	# $(GHDL) -c $(GHDLFLAGS) -r $(ETHERNET)_tb --wave=$(ETHERNET).ghw
	$(GHDL) -c $(GHDLFLAGS) -r $(UUT)_tb --wave=$(UUT).ghw
	# $(GHDL) -c $(GHDLFLAGS) -r $(CRC)_tb --wave=$(CRC).ghw

# Targets to analyze libraries
init: force
	$(GHDL) -a $(GHDLFLAGS) $(SRC)/ethernet_package.vhd
	$(GHDL) -a $(GHDLFLAGS) $(SRC)/std_logic_1164_addition.vhd

	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(ETHERNET).vhd
	$(GHDL) -a $(GHDLFLAGS) $(TB)/$(ETHERNET)_tb.vhd

	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(ETHERNET_TX).vhd
	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(ETHERNET_RX).vhd

	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(CRC).vhd
	$(GHDL) -a $(GHDLFLAGS) $(TB)/$(CRC)_tb.vhd
	
	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(TXFIFO).vhd
	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(RXFIFO).vhd
	$(GHDL) -a $(GHDLFLAGS) $(TB)/$(RXFIFO)_tb.vhd

gtk: run
	gtkwave $(ETHERNET).ghw

force:
