vlib work
vlog rtl/*.v
vlog tb/async_fifo_tb.sv
vsim -voptargs="+acc" work.async_fifo_tb
add wave -divider "Clocks & Controls"
add wave sim:/async_fifo_tb/dut/write_clk
add wave sim:/async_fifo_tb/dut/write_enable
add wave sim:/async_fifo_tb/dut/read_clk
add wave sim:/async_fifo_tb/dut/read_enable

add wave -divider "Data & Flags"
add wave -radix hexadecimal sim:/async_fifo_tb/dut/write_data
add wave -radix hexadecimal sim:/async_fifo_tb/dut/read_data
add wave sim:/async_fifo_tb/dut/write_full
add wave sim:/async_fifo_tb/dut/read_empty

add wave -divider "CDC Gray Pointers"
add wave -radix binary sim:/async_fifo_tb/dut/write_ptr_gray
add wave -radix binary sim:/async_fifo_tb/dut/sync_write_ptr_gray
add wave -radix binary sim:/async_fifo_tb/dut/read_ptr_gray
add wave -radix binary sim:/async_fifo_tb/dut/sync_read_ptr_gray
run -all