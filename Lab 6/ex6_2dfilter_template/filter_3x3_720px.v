/*
	Author:  Yee Yang Tan
	Last modified:  16/04/2020
*/

module filter_3x3_720px
#(
	 parameter BLOCK_LENGTH = 720,

    // weight of each pixel, change these parameters to make difference effect of filter
	// |WA3|WB3|WA3|
	// |WB3|WA1|WB3|
	// |WA3|WB3|WA3|
	parameter WA3 = 0,
			  WB3 = 1,
			  WA1 = -4,

	parameter DIV = 1
)
(
	// system
	input	reset,
	input	clk,

	// io
	input [15:0] d_in,
	output wire [15:0] d_out,

	// control
	input wren,
	output wire d_rdy,
	input [9:0] cursor

);


	// 3 cursors delay, because of the ram required 3 clk cycle to output the data to 'q'
	reg [9:0] cursor1, cursor2, cursor3;

	always @ (posedge clk) begin
        if (reset == 1) begin
            cursor1 <= 0;
            cursor2 <= 0;
            cursor3 <= 0;
        end
        else begin
            cursor1 <= cursor;
            cursor2 <= cursor1;
            cursor3 <= cursor2;
        end
	end


	// enable signal for each row of ram
	

	// flag to determine the middle px
	

	// address of each ram
	
    // If the ram is not used, the address value of the ram is 0xFF
	
	// memory output of ram
	

	// filter color data



	// filtered RGB

	

	// final filtered data
	

	// output data
	

	// data ready signal for write_filter_tb
	// assign d_rdy = (wren == 0) & ((cursor == cursor3)|~flag_cursor_mid);
	


	// connection of wire and ram

   

endmodule