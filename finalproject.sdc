#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "10.0 MHz" [get_ports ADC_CLK_10]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK2_50]




# SDRAM CLK
create_generated_clock -source [get_pins { m_lab61_soc|sdram_pll|sd1|pll7|clk[1] }] \
                      -name clk_dram_ext [get_ports {DRAM_CLK}]
# create_generated_clock -source [get_pins { u0|altpll_0|sd1|pll7|clk[1] }] \
                      -name clk_dram_ext [get_ports {DRAM_CLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************
# suppose +- 100 ps skew
# Board Delay (Data) + Propagation Delay - Board Delay (Clock)
# max 5.4(max) +0.4(trace delay) +0.1 = 5.9
# min 2.7(min) +0.4(trace delay) -0.1 = 3.0
set_input_delay -max -clock clk_dram_ext 5.9 [get_ports DRAM_DQ*]
set_input_delay -min -clock clk_dram_ext 3.0 [get_ports DRAM_DQ*]

#shift-window
set_multicycle_path -from [get_clocks {clk_dram_ext}] \
                    -to [get_clocks { m_lab61_soc|sdram_pll|sd1|pll7|clk[0] }] \
						  -setup 2
						  
#**************************************************************
# Set Output Delay
#**************************************************************
# suppose +- 100 ps skew
# max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
# min : Board Delay (Data) - Board Delay (Clock) - th (External Device)
# max 1.5+0.1 =1.6
# min -0.8-0.1 = 0.9
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

# inputs:
set_false_path -from [get_ports KEY*] -to *
set_false_path -from [get_ports SW*] -to *

#outputs:
set_false_path -from * -to [get_ports LEDR*]
set_false_path -from * -to [get_ports DRAM_ADDR*]
set_false_path -from * -to [get_ports DRAM_BA*]
set_false_path -from * -to [get_ports DRAM_CAS_N*]
set_false_path -from * -to [get_ports DRAM_CKE*]
set_false_path -from * -to [get_ports DRAM_CS_N*]
set_false_path -from * -to [get_ports DRAM_DQ*]
set_false_path -from * -to [get_ports DRAM_UDQM*]
set_false_path -from * -to [get_ports DRAM_LDQM*]
set_false_path -from * -to [get_ports DRAM_RAS_N*]
set_false_path -from * -to [get_ports DRAM_WE_N*]

#Altera Stuff
#inputs:
set_false_path -from [get_ports altera_reserved_tdi*] -to *
set_false_path -from [get_ports altera_reserved_tms*] -to *

#outputs:
set_false_path -from * -to [get_ports altera_reserved_tdo*]


#6.2 Stuff:
#inputs:
#
#set_false_path -from [get_ports ARDUINO_IO[9]*] -to *
#set_false_path -from [get_ports ARDUINO_IO[12]*] -to *
#set_false_path -from [get_ports DRAM_DQ[0]*] -to *
#set_false_path -from [get_ports DRAM_DQ[1]*] -to *
#set_false_path -from [get_ports DRAM_DQ[2]*] -to *
#set_false_path -from [get_ports DRAM_DQ[3]*] -to *
#set_false_path -from [get_ports DRAM_DQ[4]*] -to *
#set_false_path -from [get_ports DRAM_DQ[5]*] -to *
#set_false_path -from [get_ports DRAM_DQ[6]*] -to *
#set_false_path -from [get_ports DRAM_DQ[7]*] -to *
#set_false_path -from [get_ports DRAM_DQ[8]*] -to *
#set_false_path -from [get_ports DRAM_DQ[9]*] -to *
#set_false_path -from [get_ports DRAM_DQ[10]*] -to *
#set_false_path -from [get_ports DRAM_DQ[11]*] -to *
#set_false_path -from [get_ports DRAM_DQ[12]*] -to *
#set_false_path -from [get_ports DRAM_DQ[13]*] -to *
#set_false_path -from [get_ports DRAM_DQ[14]*] -to *
#set_false_path -from [get_ports DRAM_DQ[15]*] -to *
#
##outputs:
#set_false_path -from * -to [ARDUINO_IO[7]*]
#set_false_path -from * -to [ARDUINO_IO[10]*]
#set_false_path -from * -to [ARDUINO_IO[11]*]
#set_false_path -from * -to [ARDUINO_IO[13]*]
#set_false_path -from * -to [ARDUINO_RESET_N*]
#set_false_path -from * -to [DRAM_CLK*]
#
#set_false_path -from * -to [HEX0[0]*]
#set_false_path -from * -to [HEX0[1]*]
#set_false_path -from * -to [HEX0[2]*]
#set_false_path -from * -to [HEX0[3]*]
#set_false_path -from * -to [HEX0[4]*]
#set_false_path -from * -to [HEX0[5]*]
#set_false_path -from * -to [HEX0[6]*]
#
#set_false_path -from * -to [HEX1[0]*]
#set_false_path -from * -to [HEX1[1]*]
#set_false_path -from * -to [HEX1[2]*]
#set_false_path -from * -to [HEX1[3]*]
#set_false_path -from * -to [HEX1[4]*]
#set_false_path -from * -to [HEX1[5]*]
#set_false_path -from * -to [HEX1[6]*]
#
#set_false_path -from * -to [HEX2[0]*]
#set_false_path -from * -to [HEX2[1]*]
#set_false_path -from * -to [HEX2[2]*]
#set_false_path -from * -to [HEX2[3]*]
#set_false_path -from * -to [HEX2[4]*]
#set_false_path -from * -to [HEX2[5]*]
#set_false_path -from * -to [HEX2[6]*]
#
#set_false_path -from * -to [HEX3[0]*]
#set_false_path -from * -to [HEX3[1]*]
#set_false_path -from * -to [HEX3[2]*]
#set_false_path -from * -to [HEX3[3]*]
#set_false_path -from * -to [HEX3[4]*]
#set_false_path -from * -to [HEX3[5]*]
#set_false_path -from * -to [HEX3[6]*]
#
#set_false_path -from * -to [HEX4[0]*]
#set_false_path -from * -to [HEX4[1]*]
#set_false_path -from * -to [HEX4[2]*]
#set_false_path -from * -to [HEX4[3]*]
#set_false_path -from * -to [HEX4[4]*]
#set_false_path -from * -to [HEX4[5]*]
#set_false_path -from * -to [HEX4[6]*]
#
#set_false_path -from * -to [HEX5[0]*]
#set_false_path -from * -to [HEX5[1]*]
#set_false_path -from * -to [HEX5[2]*]
#set_false_path -from * -to [HEX5[3]*]
#set_false_path -from * -to [HEX5[4]*]
#set_false_path -from * -to [HEX5[5]*]
#set_false_path -from * -to [HEX5[6]*]
#
#set_false_path -from * -to [VGA_B[0]*]
#set_false_path -from * -to [VGA_B[1]*]
#set_false_path -from * -to [VGA_B[2]*]
#set_false_path -from * -to [VGA_G[0]*]
#set_false_path -from * -to [VGA_G[2]*]
#set_false_path -from * -to [VGA_HS*]
#set_false_path -from * -to [VGA_R[0]*]
#set_false_path -from * -to [VGA_R[1]*]
#set_false_path -from * -to [VGA_R[2]*]
#set_false_path -from * -to [VGA_R[3]*]
#set_false_path -from * -to [VGA_VS*]



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************

