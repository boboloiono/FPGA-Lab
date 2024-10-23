//Testbench for the top module for the 8 bit counter
//17.07.2018 Cecilia Hoeffler
//`timescale 1 ps / 1 ps
module tb_top(
);


reg clock;
reg rst;
reg udc;
wire [7:0] LEDs;

top DUT(
	.clock_5(clock),
	.reset(rst),
	.key1(udc),
	.LED(LEDs)
);



 //----------------------------------------------------------
 // create a 50Mhz clock
 always
 #10 clock = ~clock; // every ten nanoseconds invert
 //-----------------------------------------------------------
 // initial blocks are sequential and start at time 
 initial
 begin
 $display($time, " << Starting the Simulation >>");
 clock = 1'b0;
 rst = 1'b0;
 udc = 1'b1;

#20 rst = 1'b0;
#20 rst = 1'b1;
#100 udc = 1'b0;
#300 udc = 1'b1;
#200 rst = 1'b0;
#200 rst = 1'b1;

 end
endmodule
