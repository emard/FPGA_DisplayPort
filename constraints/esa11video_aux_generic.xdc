##Clock Signal
#set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS25} [get_ports clk100]
#create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100]

#
#	System Clock for ESA11
#
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVDS_25} [get_ports i_100MHz_N]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVDS_25} [get_ports i_100MHz_P]
create_clock -name {sys_clk_pin}  [get_ports {i_100MHz_P}] -period {10.000}  -add 

set_property CFGBVS VCCO [current_design]

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
# actually connected to ethernet TXD0/TXD1
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports dp_rx_aux_n]
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVCMOS33} [get_ports dp_rx_aux_p]


# DEBUG on JA
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports {debug[0]}]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports {debug[1]}]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33} [get_ports {debug[2]}]
set_property -dict {PACKAGE_PIN AB18 IOSTANDARD LVCMOS33} [get_ports {debug[3]}]
set_property -dict {PACKAGE_PIN  Y21 IOSTANDARD LVCMOS33} [get_ports {debug[4]}]
set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS33} [get_ports {debug[5]}]
set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33} [get_ports {debug[6]}]
set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33} [get_ports {debug[7]}]


#create_clock -period 7.407 -name i_tx0/I -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_i/TXOUTCLK]
#create_clock -period 7.407 -name i_tx0/ref_clk -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_i/TXOUTCLKFABRIC]


create_clock -period 7.407 -name i_tx0/TXOUTCLK -waveform {0.000 3.704} [get_pins {i_tx0/g_tx[0].gtpe2_i/TXOUTCLK}]
create_clock -period 7.407 -name {i_tx0/g_tx[1].gtpe2_i_n_39} -waveform {0.000 3.704} [get_pins {i_tx0/g_tx[1].gtpe2_i/TXOUTCLKFABRIC}]
create_clock -period 7.407 -name i_tx0/ref_clk -waveform {0.000 3.704} [get_pins {i_tx0/g_tx[0].gtpe2_i/TXOUTCLKFABRIC}]


create_clock -period 7.407 -name i_tx0/PLL0CLK -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_common_i/PLL0OUTCLK]
create_clock -period 7.407 -name i_tx0/PLL1CLK -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_common_i/PLL1OUTCLK]
create_clock -period 7.407 -name refclk0_p -waveform {0.000 3.704} [get_ports refclk0_p]
create_clock -period 7.407 -name refclk1_p -waveform {0.000 3.704} [get_ports refclk1_p]
