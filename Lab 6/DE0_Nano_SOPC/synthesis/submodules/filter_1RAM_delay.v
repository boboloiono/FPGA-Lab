/*
	Author:  Yee Yang Tan
	Last modified:  16/04/2020
*/

module filter_1RAM_delay
#(
    parameter BLOCK_LENGTH = 240
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
            cursor1 <= cursor;
            cursor2 <= cursor1;
            cursor3 <= cursor2;
	end

    wire [9:0] addr;
    wire [15:0] q;

    ram ram(
        .address(addr),
        .clock(clk),
        .data(d_in),
        .wren(wren),
        .q(q)
    );

    assign addr = cursor;

    assign d_rdy = (cursor == cursor3) & (wren == 0);

    assign d_out = q;

endmodule