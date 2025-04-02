# Create a new project in the same directory as this script
create_project -force nms_simple_project ./nms_simple_project -part xc7z020clg484-1

# Add source files
add_files ./testBench/non_max_suppresion_simp_tb.sv
add_files ./non_max_suppression.sv

# Set the top module
set_property top non_max_suppresion_simple_tb [get_filesets sim_1]

# Launch the simulation
launch_simulation

# Run the simulation
run all

# Start the GUI to view the waveform
start_gui
