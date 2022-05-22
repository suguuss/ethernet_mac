UNITNAME=ethernet
UNITNAME1=frame_gen


SRC=src
TB=tb

GHDL=ghdl
GHDLFLAGS=
GHDLRUNFLAGS=--vcd=$(UNITNAME).vcd

# Default target : elaborate
all : init elab

# Elaborate target.  Almost useless
elab : force
	$(GHDL) -c $(GHDLFLAGS) -e $(UNITNAME)

# Run target
run : force
	# $(GHDL) -c $(GHDLFLAGS) -r $(SRC)/$(UNITNAME) $(GHDLRUNFLAGS)
	$(GHDL) -c $(GHDLFLAGS) -r $(UNITNAME)_tb $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: force
	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(UNITNAME).vhd
	$(GHDL) -a $(GHDLFLAGS) $(TB)/$(UNITNAME)_tb.vhd
	$(GHDL) -a $(GHDLFLAGS) $(SRC)/$(UNITNAME1).vhd
	$(GHDL) -a $(GHDLFLAGS) $(TB)/$(UNITNAME1)_tb.vhd

gtk: run
	gtkwave $(UNITNAME).vcd

force:
