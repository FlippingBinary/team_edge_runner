#!/usr/bin/env tclsh

proc send_file {source server destination} {
  set timestamp [clock format [clock seconds] -format "%Y%m%d%H%M%S"]
  
  # Function to create mkdir commands for all parent directories
  proc create_mkdir_commands {path} {
    set parts [split $path "/"]
    set parent_path ""
    set cmds ""
    foreach part $parts {
      if {$part ne ""} {
        append parent_path "$part"
        if {[llength $parts] > 1} {
          append cmds "-mkdir $parent_path\n"
        }
        append parent_path "/"
        set parts [lrange $parts 1 end]
      }
    }
    return $cmds
  }

  # Create mkdir commands for the destination and trash paths
  set commands [create_mkdir_commands "$destination/$source"]
  append commands [create_mkdir_commands ".trash/${timestamp}_$destination/$source"]

  # Define the SFTP batch commands
  append commands "-rename $destination/$source .trash/${timestamp}_$destination/$source\n"
  append commands "put $source $destination/$source"

  # Execute sftp with the script and interactive password prompt
  if {[string equal $::tcl_platform(platform) "windows"]} {
    exec -ignorestderr sftp -q -P 222 -oHostKeyAlgorithms=+ssh-rsa -oStrictHostKeyChecking=no $server << $commands 2>NUL
  } else {
    exec -ignorestderr sftp -q -P 222 -oHostKeyAlgorithms=+ssh-rsa -oStrictHostKeyChecking=no $server << $commands 2>/dev/null
  }
}

if { $argc != 2 } {
  puts "Usage: $argv0 <source_file> <username>@<server>:<destination>"
  puts "Example: $argv0 simulation/create_vivado_project.tcl bob@127.2.6.6:canny_edge"
  exit 1
}

set source_file [lindex $argv 0]
set server_destination [lindex $argv 1]

# Split the server and destination
regexp {([^@]+@[^:]+):(.*)} $server_destination -> server destination

send_file $source_file $server $destination
