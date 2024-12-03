/*
	Author:  Yee Yang Tan
	Last modified:  16/04/2020
*/

module filter_Multi_RAM_preempt
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
        else if (count != 3) begin
			count <= count + 1;
            if (count == 3)
                flag <= 1;
        end
    end

	// give signal to certain inner _cursor_ to increase the each ram address value by 3.
	reg s1, s2, s3;
	always @(posedge clk) begin
		if ( wren == 1 | reset == 1) begin
			s1 <= 0;
			s2 <= 0;
			s3 <= 1;
		end
		else if ( d_rdy_inner == 1) begin
			s1 <= s3;
			s2 <= s1;
			s3 <= s2;
		end
	end

	// increase each cursor value
	reg [7:0] _cursor1_, _cursor2_, _cursor3_;
	always @(posedge clk) begin
		if ( wren == 1 | reset == 1) begin
			_cursor1_ <= 1;
			_cursor2_ <= 2;
			_cursor3_ <= 0;
		end
		else if ( d_rdy_inner == 1) begin

			if (s1 == 1)
				_cursor1_ <= _cursor1_ + 3;

			if (s2 == 1)
				_cursor2_ <= _cursor2_ + 3;

			if (s3 == 1)
				_cursor3_ <= _cursor3_ + 3;

		end
	end

    // this is the inner _cursor_ to indicate the synchronization with the cursor in ci custom master
    // if _cursor_ or cursor is less than other, the leading cursor will wait for other cursor to increase
	wire [7:0] _cursor_;

	assign _cursor_ = s1? _cursor1_ : s2? _cursor2_ : _cursor3_;

	// synchronize inner and outer cursor
	reg d_rdy_inner;
	reg d_rdy_outer;
	always @(posedge clk) begin

		if (wren == 1) begin
			d_rdy_inner <= 0;
			d_rdy_outer <= 0;
		end
		else if (flag == 1) begin

			if (cursor[7:0] == _cursor_) begin
				d_rdy_inner <= 1;
				d_rdy_outer <= 1;
			end
			else if (cursor[7:0] < _cursor_) begin
				d_rdy_inner <= 0;
				d_rdy_outer <= 1;
			end
			else if(cursor[7:0] > _cursor_) begin
				d_rdy_inner <= 1;
				d_rdy_outer <= 0;
			end

		end
	end


	assign d_rdy = d_rdy_outer;

	wire [7:0] addr1, addr2, addr3;

	assign addr1 = (wren)? cursor[7:0] : _cursor1_;
	assign addr2 = (wren)? cursor[7:0] : _cursor2_;
	assign addr3 = (wren)? cursor[7:0] : _cursor3_;

	wire [15:0] q1, q2, q3;

	assign d_out = (s1) ? q1 : (s2) ? q2 : q3;

	ram ram1
	(
		.clock(clk),
		.address(addr1),
		.wren(wren),
		.data(d_in),
		.q(q1)
	);

	ram ram2
	(
		.clock(clk),
		.address(addr2),
		.wren(wren),
		.data(d_in),
		.q(q2)
	);

	ram ram3
	(
		.clock(clk),
		.address(addr3),
		.wren(wren),
		.data(d_in),
		.q(q3)
	);

endmodule