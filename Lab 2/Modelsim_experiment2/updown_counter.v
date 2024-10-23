// created 17.07.2018 by Cecilia Hoeffler
// Up-Down Counter Template for Experiment 2
// This counter allows control of LEDs via key[0] and key[1]

module updown_counter(
    input up_down,   // if up_down is ‘1’ it counts up, else if ‘0’ it counts down
    input clk,       // clock signal
    input enable,    // enable counting
    input reset,     // asynchronous reset
    output reg [7:0] count_out  // 8-bit counter output
);

    always @(posedge clk) begin
        if (!reset) 
            count_out <= 8'b0; // Reset counter to 0
        else if (enable) begin
			count_out <= (up_down) ? count_out + 1 : count_out - 1;
		end
    end

endmodule
