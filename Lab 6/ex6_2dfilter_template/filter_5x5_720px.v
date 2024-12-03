/*
	Author:  Yee Yang Tan
	Last modified:  16/04/2020
*/

module filter_5x5_720px
#(
    parameter BLOCK_LENGTH = 720,

    // weight of each pixel, change these parameters to make difference effect of filter
    // |WA5|WB5|WC5|WB5|WA5|
    // |WB5|WA3|WB3|WA3|WB5|
    // |WC5|WB3|WA1|WB3|WC5|
    // |WB5|WA3|WB3|WA3|WB5|
    // |WA5|WB5|WC5|WB5|WA5|
    parameter   WA5 = 0,
                WB5 = 0,
                WC5 = 1,
                WA3 = 1,
                WB3 = 2,
                WA1 = -16,

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


	// flag to determine the middle px
	

	// State to determine the position of each row of ram
	// state for reading data from ram

	
	// state for writing the data to the ram
	
	// state for reading the data from the ram
	

	// writing enable signal for each 3 row
	
	// writing enable signal for each row of ram

	

	// address for each ram
	
    // If the ram is not used, the address value of the ram is 0xFF


	// memory output of the ram to filter decision
	

	// the correct position of the matrix, since the position of each ram depends on the state
	
    // seperate the RGB of the value from f_xy.
	


    // filtered data RGB
    

    // final filtered data
    

    // output data
    

	// data ready signal for write_filter_tb
	// assign d_rdy = (wren == 0) & ((cursor == cursor3)|~flag_cursor_mid);


    // connection of wire with rams

    


endmodule
