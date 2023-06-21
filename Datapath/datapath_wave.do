onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Datapath_tb/clk
add wave -noupdate /Datapath_tb/IR
add wave -noupdate /Datapath_tb/rdAddrA
add wave -noupdate /Datapath_tb/rdAddrB
add wave -noupdate /Datapath_tb/WriteAddr
add wave -noupdate /Datapath_tb/D_addr
add wave -noupdate /Datapath_tb/D_wr
add wave -noupdate /Datapath_tb/RF_sel
add wave -noupdate /Datapath_tb/RF_W_en
add wave -noupdate /Datapath_tb/ALU_s0
add wave -noupdate /Datapath_tb/ALU_A_out
add wave -noupdate /Datapath_tb/DUT.Ra_data
add wave -noupdate /Datapath_tb/ALU_B_out
add wave -noupdate /Datapath_tb/DUT.Rb_data
add wave -noupdate /Datapath_tb/ALUout
add wave -noupdate /Datapath_tb/DUT.Wr_Data
add wave -noupdate /Datapath_tb/DUT.Data_to_Mux

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
