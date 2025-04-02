# Create the Vivado/Journals and Vivado/Logs directories if they do not exist
file mkdir ./Vivado/Journals
file mkdir ./Vivado/Logs

# Create a new project in the same directory as this script
create_project -force nms_project Vivado/Sims -part xc7z020clg484-1

# Add source files
add_files ./testBench/non_max_suppression_tb.sv
add_files ./Non_Max_Suppresion.sv
add_files ./pixel_loader.sv
add_files ./gaussian_filter.sv
add_files ./gradient_calculation.sv
add_files ./definitions_pkg.sv
add_files ./line_buffer.sv
add_files ./sqrt_22b.sv
add_files ./arc_tan.sv

# Create the target directory for the testImages folder
file mkdir ./Vivado/Sims/nms_project.sim/sim_1/behav/xsim/

# Copy the entire testImages folder to the simulation directory
if {[file exists ./testImages]} {
    file copy -force ./testImages ./Vivado/Sims/nms_project.sim/sim_1/behav/xsim/
} else {
    puts "Warning: testImages folder does not exist."
}

# Control where the simulation files go 
set_property directory Vivado/Sims [get_filesets sim_1]

# Set the top module
set_property top nms_tb [get_filesets sim_1]

# Launch the simulation
launch_simulation

# Run the simulation
run 2000ns

# Move stray backup log and journal files to Vivado folder
move_to_dir [glob -nocomplain *.backup.log] ./Vivado/Logs
move_to_dir [glob -nocomplain *.backup.jou] ./Vivado/Journals

proc move_to_dir {filenames dirname} {
    foreach filename $filenames {
        file rename $filename [file join $dirname [file tail $filename]]
    }
}

puts "Simulation complete. Results available in Vivado/Sims"
puts "All backup log and journal files have been swept into Vivado/Logs and Vivado/Journals, respectively"
