#!/bin/sh

# Propery of Tecphos Inc.  See WrimmLicense.txt for license details
# Latest version of all Wrimm project files available at http://opencores.org/project,wrimm
# See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
# See wrimm subversion project for version history

#GHDL simulation script and gtkWave view of results

ghdl -i -v --workdir=work *.vhd

ghdl -m --workdir=work wrimm_top_tb

ghdl -r wrimm_top_tb --vcd=wrimm.vcd --assert-level=warning --stop-time=119ns

# gtkwave wrimm.vcd
