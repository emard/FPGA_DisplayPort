#
#	System Clock for ESA11
#
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVDS_25} [get_ports i_100MHz_N]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVDS_25} [get_ports i_100MHz_P]
create_clock -name {sys_clk_pin}  [get_ports {i_100MHz_P}] -period {10.000}  -add 

set_property CFGBVS VCCO [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
#where value2 is the voltage provided to configuration bank 0

##Display Port
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports dp_tx_aux_n]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports dp_tx_aux_p]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports dp_tx_hp_detect]
set_property -dict {PACKAGE_PIN F6} [get_ports refclk0_p]
set_property -dict {PACKAGE_PIN E6} [get_ports refclk0_n]
set_property -dict {PACKAGE_PIN F10} [get_ports refclk1_p]
set_property -dict {PACKAGE_PIN E10} [get_ports refclk1_n]
set_property -dict {PACKAGE_PIN B4} [get_ports {gtptxp[0]}]
set_property -dict {PACKAGE_PIN A4} [get_ports {gtptxn[0]}]
set_property -dict {PACKAGE_PIN D5} [get_ports {gtptxp[1]}]
set_property -dict {PACKAGE_PIN C5} [get_ports {gtptxn[1]}]

# on ESA11 these are not connected to DisplayPort
# they are also not used by the modules
# actually connected to ethernet TXD0/TXD1
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports dp_rx_aux_n]
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVCMOS33} [get_ports dp_rx_aux_p]


# mainboard 3 green LEDs
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
# add-on board USER02 green LEDs
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {led[7]}]


#create_clock -period 7.407 -name i_tx0/I -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_i/TXOUTCLK]
#create_clock -period 7.407 -name i_tx0/ref_clk -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_i/TXOUTCLKFABRIC]

create_clock -period 7.407 -name i_tx0/TXOUTCLK -waveform {0.000 3.704} [get_pins {i_tx0/g_tx[0].gtpe2_i/TXOUTCLK}]
create_clock -period 7.407 -name {i_tx0/g_tx[1].gtpe2_i_n_39} -waveform {0.000 3.704} [get_pins {i_tx0/g_tx[1].gtpe2_i/TXOUTCLKFABRIC}]
create_clock -period 7.407 -name i_tx0/ref_clk -waveform {0.000 3.704} [get_pins {i_tx0/g_tx[0].gtpe2_i/TXOUTCLKFABRIC}]

create_clock -period 7.407 -name i_tx0/PLL0CLK -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_common_i/PLL0OUTCLK]
create_clock -period 7.407 -name i_tx0/PLL1CLK -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_common_i/PLL1OUTCLK]
create_clock -period 7.407 -name refclk0_p -waveform {0.000 3.704} [get_ports refclk0_p]
create_clock -period 7.407 -name refclk1_p -waveform {0.000 3.704} [get_ports refclk1_p]
