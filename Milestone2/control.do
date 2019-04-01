# cd palaci37/CSC258/Music_viz

# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ps/1ps control.v

# Load simulation using mux as the top level simulation module.
vsim control

# Log all signals and add some signals to waveform window.
log {/*}

# add wave {/*} would add all items in top level simulation module.
add wave {/*}
# add wave {/music_viz2/c0/c/*}
# add wave {/music_viz2/d0/coordinates/*}

force {clk} 0 0, 1 20 -r 40
force {resetn} 0 0 ps, 1 40 ps, 1 50000 ps , 1 50500 ps
force {visualize} 0 0 ps, 0 40 ps, 1 50000 ps, 0 50500 ps
force {busy} 0 0 ps, 1 51500 ps, 0 55000 ps
force {done_counting} 1
force {colour_in[2]} 1
force {colour_in[1]} 1
force {colour_in[0]} 1

run 250000 ps 
