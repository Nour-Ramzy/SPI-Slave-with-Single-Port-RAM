vlib work
vlog RAM.v SLAVE.v TOP_Wrapper.v Master_tb.v
vsim -voptargs=+acc work.master_tb
add wave *
add wave -position insertpoint  \
sim:/master_tb/my_spi/dut2/mem
add wave -position insertpoint  \
sim:/master_tb/my_spi/dut2/rd_addr \
sim:/master_tb/my_spi/dut2/wr_addr
add wave -position insertpoint  \
sim:/master_tb/my_spi/dut2/tx_valid
add wave -position insertpoint  \
sim:/master_tb/my_spi/dut2/rx_valid
run -all
#quit -sim