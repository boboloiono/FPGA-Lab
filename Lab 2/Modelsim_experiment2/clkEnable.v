// created 17.07.2018 by Cecilia Hoeffler
// template for experiment 2
//you should be able to reduce the frequency of the clock with this module


module clkEnable(
			input clock_5,
			input reset,
			output enable_out
			);
							
			parameter freq_divider = 24'd5; // 5M/10M = 0.5/s
			reg enable;
			reg [31:0] count;
			
			always @(posedge clock_5) begin
				if (!reset) begin
					enable <= 1'b0;
					count <= 32'b0;
				end
				else begin
					if (count >= freq_divider) begin
						enable <= 1'b1;
						count <= 32'b0;
					end
					else begin
						enable <= 1'b0;
						count <= count + 1'b1;
					end
				end
			end
			assign enable_out = enable;
endmodule