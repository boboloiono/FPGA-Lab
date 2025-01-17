# TCL File Generated by Component Editor 17.0
# Fri Jul 27 11:51:24 CEST 2018
# DO NOT MODIFY


# 
# new_component "new_component" v1.0
#  2018.07.27.11:51:24
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module new_component
# 
set_module_property DESCRIPTION ""
set_module_property NAME new_component
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME new_component
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL CI_custom_master
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file CI_custom_master.v VERILOG PATH ex6_2dfilter_lsg/CI_custom_master.v TOP_LEVEL_FILE
add_fileset_file filter_2D_par.v VERILOG PATH ex6_2dfilter_lsg/filter_2D_par.v
add_fileset_file filter_2D_seq.v VERILOG PATH ex6_2dfilter_lsg/filter_2D_seq.v
add_fileset_file read_master.v VERILOG PATH ex6_2dfilter_lsg/read_master.v
add_fileset_file write_master.v VERILOG PATH ex6_2dfilter_lsg/write_master.v


# 
# parameters
# 
add_parameter LATENCY INTEGER 0
set_parameter_property LATENCY DEFAULT_VALUE 0
set_parameter_property LATENCY DISPLAY_NAME LATENCY
set_parameter_property LATENCY TYPE INTEGER
set_parameter_property LATENCY UNITS None
set_parameter_property LATENCY HDL_PARAMETER true


# 
# display items
# 


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point nios_custom_instruction_slave
# 
add_interface nios_custom_instruction_slave nios_custom_instruction end
set_interface_property nios_custom_instruction_slave clockCycle 0
set_interface_property nios_custom_instruction_slave operands 2
set_interface_property nios_custom_instruction_slave ENABLED true
set_interface_property nios_custom_instruction_slave EXPORT_OF ""
set_interface_property nios_custom_instruction_slave PORT_NAME_MAP ""
set_interface_property nios_custom_instruction_slave CMSIS_SVD_VARIABLES ""
set_interface_property nios_custom_instruction_slave SVD_ADDRESS_GROUP ""

add_interface_port nios_custom_instruction_slave clk_custom clk Input 1
add_interface_port nios_custom_instruction_slave clk_en clk_en Input 1
add_interface_port nios_custom_instruction_slave dataa dataa Input 32
add_interface_port nios_custom_instruction_slave datab datab Input 32
add_interface_port nios_custom_instruction_slave done done Output 1
add_interface_port nios_custom_instruction_slave result result Output 32
add_interface_port nios_custom_instruction_slave rst_custom reset Input 1
add_interface_port nios_custom_instruction_slave start start Input 1


# 
# connection point avalon_master
# 
add_interface avalon_master avalon start
set_interface_property avalon_master addressUnits SYMBOLS
set_interface_property avalon_master associatedClock clock
set_interface_property avalon_master associatedReset reset
set_interface_property avalon_master bitsPerSymbol 8
set_interface_property avalon_master burstOnBurstBoundariesOnly false
set_interface_property avalon_master burstcountUnits WORDS
set_interface_property avalon_master doStreamReads false
set_interface_property avalon_master doStreamWrites false
set_interface_property avalon_master holdTime 0
set_interface_property avalon_master linewrapBursts false
set_interface_property avalon_master maximumPendingReadTransactions 0
set_interface_property avalon_master maximumPendingWriteTransactions 0
set_interface_property avalon_master readLatency 0
set_interface_property avalon_master readWaitTime 1
set_interface_property avalon_master setupTime 0
set_interface_property avalon_master timingUnits Cycles
set_interface_property avalon_master writeWaitTime 0
set_interface_property avalon_master ENABLED true
set_interface_property avalon_master EXPORT_OF ""
set_interface_property avalon_master PORT_NAME_MAP ""
set_interface_property avalon_master CMSIS_SVD_VARIABLES ""
set_interface_property avalon_master SVD_ADDRESS_GROUP ""

add_interface_port avalon_master master_address address Output 32
add_interface_port avalon_master master_read read Output 1
add_interface_port avalon_master master_write write Output 1
add_interface_port avalon_master master_byteenable byteenable Output 2
add_interface_port avalon_master master_readdata readdata Input 16
add_interface_port avalon_master master_readdatavalid readdatavalid Input 1
add_interface_port avalon_master master_writedata writedata Output 16
add_interface_port avalon_master master_burstcount burstcount Output 3
add_interface_port avalon_master master_waitrequest waitrequest Input 1

