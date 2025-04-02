# Create the Vivado/Journals and Vivado/Logs directories if they do not exist
file mkdir ./Vivado/Journals
file mkdir ./Vivado/Logs

# Create a new project in the same directory as this script
create_project -force uart_project Vivado/Sims -part xc7z020clg484-1

# Add source files
add_files ./definitions_pkg.sv
add_files ./uart/kennedy/baud_gen.sv
add_files ./uart/kennedy/Divisor.sv
add_files ./uart/kennedy/FIFO.sv
add_files ./uart/kennedy/Kennedy_receiver.sv
add_files ./uart/kennedy/Kennedy_Transmitter.sv
add_files ./uart/kennedy/Mensah_UART.sv
add_files ./uart/kennedy/Testing/Kennedy_transmitter_tb.sv

# Create the target directory for the testImages folder
file mkdir ./Vivado/Sims/uart_project.sim/sim_1/behav/xsim/
if {[file exists ./uart/kennedy/Testing]} {
    file copy -force ./uart/kennedy/Testing ./Vivado/Sims/nms_project.sim/sim_1/behav/xsim/
} else {
    puts "Warning: testImages folder does not exist."
}

# Control where the simulation files go 
set_property directory Vivado/Sims [get_filesets sim_1]

# Set the top module
set_property top tb_Kennedy_Transmitter [get_filesets sim_1]

# Launch the simulation
launch_simulation

# Run the simulation for 150000ns
run 150000ns

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

# Prompt user about opening waveform
puts -nonewline "Would you like to open the waveform viewer? (y/n): "
flush stdout
gets stdin response

if {[string tolower $response] == "y" || [string tolower $response] == "yes"} {
    # Open the waveform viewer
    if {[file exists [current_sim]/xsim.wdb]} {
        open_wave_database [current_sim]/xsim.wdb
        display_wave -open_wave_config {}
        puts "Waveform viewer opened successfully."
    } else {
        puts "Error: Waveform database file not found."
    }
}

puts "Script completed. You can now enter additional commands."
