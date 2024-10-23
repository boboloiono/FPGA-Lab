// created 17.07.2018 by Cecilia Hoeffler
// template for experiment 2
//Up-Down- Counter, you should be able to control the LEDs via the key[0] and key[1]

module updown_counter(

input up_down, // if up_down is ‘1’ then it counts up , else if ‘0’ it counts down

input clk,

input enable,
input reset,


output reg [7:0]count_out

);
	
	always @(posedge clk) begin
		if (!reset) count_out <= 8'b0;
		else if (enable) count_out <= (up_down) ? count_out + 1'b1 : count_out - 1'b1;
		else count_out <= count_out;
	end
	
endmodule
			