#!/usr/bin/env tclsh

if {$argc != 1} {
    puts stderr "Usage: $argv0 <output_directory>"
    exit 1
}

set output_dir [lindex $argv 0]

if {![file exists $output_dir]} {
    if {[catch {file mkdir $output_dir} err]} {
        puts stderr "Error creating directory $output_dir: $err"
        exit 1
    }
} elseif {![file isdirectory $output_dir]} {
    puts stderr "$output_dir is not a directory."
    exit 1
}

# Get the clipboard contents (platform-specific)
if {[catch {package require Tk} err]} {
    puts stderr "Tk package required for clipboard access: $err"
    exit 1
}

set base64_data [clipboard get]

# Decode the base64 data
if {[catch {exec base64 -d <<< $base64_data} decoded_data]} {
    puts stderr "Error decoding base64 data: $decoded_data"
    exit 1
}

# Untar and unzip the data
if {[catch {exec tar -xz -C $output_dir <<< $decoded_data} err]} {
    puts stderr "Error untarring data: $err"
    exit 1
}

puts "Tarball extracted to $output_dir"
