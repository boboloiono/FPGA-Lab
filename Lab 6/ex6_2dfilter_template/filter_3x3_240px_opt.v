/*
	Author:  Yee Yang Tan
	Last modified:  16/04/2020
*/

module filter_3x3_240px_opt
#(
    parameter BLOCK_LENGTH = 240,

    // weight of each pixel, change these parameters to make difference effect of filter
    // |WA3|WB3|WA3|
    // |WB3|WA1|WB3|
    // |WA3|WB3|WA3|
    parameter WA3 = 0,
    parameter WB3 = 1,
    parameter WA1 = -4,
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


	// flag that indicates the output pipeline data is prepared.


	// give signal to certain inner _cursor_ to increase the each ram address value by 3.


	// increase each cursor value


    // this is the inner _cursor_ to indicate the synchronization with the cursor in ci custom master
    // if _cursor_ or cursor is less than other, the leading cursor will wait for other cursor to increase


	// synchronize inner and outer cursor



    // current active row to be written


    // writing enable signal for each row


    // 3d address: x row, y ram, z latency
 



endmodule