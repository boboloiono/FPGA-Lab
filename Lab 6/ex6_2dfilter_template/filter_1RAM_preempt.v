/*
	Author:  Yee Yang Tan
	Last modified:  16/04/2020
*/

module filter_1RAM_preempt
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

	// flag that indicates the output pipeline data is prepared.
    reg [1:0] count;
    reg flag;
    always @ (posedge clk) begin
        if (wren == 1) begin
            count <= 0;
            flag <= 0;
        end
        else begin
            count <= count + 1;
            if (count == 3)
                flag <= 1;
        end
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

    assign d_rdy = flag;

    assign d_out = q;

endmodule