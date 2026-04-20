set_app_var target_library "/home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p715v125c.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p88v125c.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/ulvl/saed14rvt_ulvl_ff0p88v125c_i0p715v.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/dlvl/saed14rvt_dlvl_ff0p715v125c_i0p88v.db"
set_app_var link_path "* \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p715v125c.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p88v125c.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/ulvl/saed14rvt_ulvl_ff0p88v125c_i0p715v.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/dlvl/saed14rvt_dlvl_ff0p715v125c_i0p88v.db"

analyze -library WORK -format verilog {../rtl/top_soc.v \
                                       ../rtl/multiplier.v \
                                       ../rtl/accumulator.v \
}

elaborate top_soc
read_file -format verilog {../rtl/top_soc.v}
current_design top_soc
link
check_design

# G4 placement UPF
load_upf design_g4.upf

# -------------------------------------------------------
# Voltage annotation (FIXED from original dc_ls.tcl)
# PD_TOP  -> VDDH = 0.88V
# PD_MUL  -> VDDL = 0.715V
# PD_ACC  -> VDDL = 0.715V
# -------------------------------------------------------
set_voltage 0.715 -object_list VDDL
set_voltage 0.88  -object_list VDDH
set_voltage 0.0   -object_list VSS

set_voltage 0.88  -object_list PD_TOP.primary.power
set_voltage 0.0   -object_list PD_TOP.primary.ground
set_voltage 0.715 -object_list PD_MUL.primary.power
set_voltage 0.0   -object_list PD_MUL.primary.ground
set_voltage 0.715 -object_list PD_ACC.primary.power
set_voltage 0.0   -object_list PD_ACC.primary.ground

check_mv_design

# -------------------------------------------------------
# Timing constraints
# -------------------------------------------------------
set PERIOD       5.0
set INPUT_DELAY  1.0
set OUTPUT_DELAY 1.0
set CLOCK_LATENCY 1.5
set MAX_TRANSITION 0.5

create_clock -name clk -period $PERIOD [get_ports clk]
set_clock_latency    $CLOCK_LATENCY [get_clocks clk]
set_clock_uncertainty 0.3           [get_clocks clk]
set_clock_transition  0.4           [get_clocks clk]

set INPUTPORTS  [remove_from_collection [all_inputs] [get_ports clk]]
set OUTPUTPORTS [all_outputs]
set_input_delay  -clock clk -max $INPUT_DELAY  $INPUTPORTS
set_output_delay -clock clk -max $OUTPUT_DELAY $OUTPUTPORTS

set_max_transition  $MAX_TRANSITION [current_design]
set_max_capacitance 100             [current_design]
set_max_fanout      200             [current_design]

set_app_var auto_wire_load_selection false
set_wire_load_model -name 8000 -library saed14rvt_base_ff0p715v125c
set_wire_load_mode top
set_operating_conditions -library saed14rvt_base_ff0p715v125c ff0p715v125c

compile_ultra

report_timing
report_area    > ./reports/top_soc_g4_area.rpt
report_power   > ./reports/top_soc_g4_power.rpt
report_timing  > ./reports/top_soc_g4_timing.rpt
report_qor     > ./reports/top_soc_g4_qor.rpt
write -format verilog -hierarchy -output ./reports/top_soc_g4_netlist.v
write_sdc ./reports/top_soc_g4_constraints.sdc
