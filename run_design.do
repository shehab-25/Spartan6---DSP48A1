vlib work
vlog DSP.v DSP_tb.v D_FF_with_mux.v
vsim -voptargs=+acc work.DSP_tb
add wave *
run -all
#quit -sim