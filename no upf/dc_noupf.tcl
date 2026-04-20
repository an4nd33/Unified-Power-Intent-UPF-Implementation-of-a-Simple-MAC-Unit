# -------------------------------------------------------
# Library setup (ONLY base libraries)
# -------------------------------------------------------
set_app_var target_library "/home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p715v125c.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p88v125c.db"

set_app_var link_path "* \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p715v125c.db \
    /home/synopsys/installs/LIBRARIES/SAED14_EDK/SAED14nm_EDK_STD_RVT/liberty/nldm/base/saed14rvt_base_ff0p88v125c.db"

# -------------------------------------------------------
# Read RTL
# -------------------------------------------------------
analyze -library WORK -format verilog {../rtl/top_soc.v \
                                       ../rtl/multiplier.v \
                                       ../rtl/accumulator.v \
}

elaborate top_soc
read_file -format verilog {../rtl/top_soc.v}
current_design top_soc
link
check_design

# -------------------------------------------------------
# Timing constraints
# -------------------------------------------------------
set PERIOD          5.0
set INPUT_DELAY     1.0
set OUTPUT_DELAY    1.0
set CLOCK_LATENCY   1.5
set MAX_TRANSITION  0.5

create_clock -name clk -period $PERIOD [get_ports clk]
set_clock_latency     $CLOCK_LATENCY [get_clocks clk]
set_clock_uncertainty 0.3            [get_clocks clk]
set_clock_transition  0.4            [get_clocks clk]

set INPUTPORTS  [remove_from_collection [all_inputs] [get_ports clk]]
set OUTPUTPORTS [all_outputs]

set_input_delay  -clock clk -max $INPUT_DELAY  $INPUTPORTS
set_output_delay -clock clk -max $OUTPUT_DELAY $OUTPUTPORTS

set_max_transition  $MAX_TRANSITION [current_design]
set_max_capacitance 100             [current_design]
set_max_fanout      200             [current_design]

# -------------------------------------------------------
# Wire load + operating conditions
# -------------------------------------------------------
set_app_var auto_wire_load_selection false
set_wire_load_model -name 8000 -library saed14rvt_base_ff0p715v125c
set_wire_load_mode top

set_operating_conditions -library saed14rvt_base_ff0p715v125c ff0p715v125c

# -------------------------------------------------------
# Compile
# -------------------------------------------------------
compile_ultra

# -------------------------------------------------------
# Reports
# -------------------------------------------------------
report_timing
report_area    > ./reports/top_soc_area.rpt
report_power   > ./reports/top_soc_power.rpt
report_timing  > ./reports/top_soc_timing.rpt
report_qor     > ./reports/top_soc_qor.rpt

# -------------------------------------------------------
# Outputs
# -------------------------------------------------------
write -format verilog -hierarchy -output ./reports/top_soc_netlist.v
write_sdc ./reports/top_soc_constraints.sdc