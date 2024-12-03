module filter_3x3_240px
#(
    parameter BLOCK_LENGTH = 240,
    parameter FILTER_SIZE = 3,

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

	// 3 cursors delay, because of the ram required 3 clk cycle to output the data to 'q'
	reg [9:0] cursor1, cursor2, cursor3;

	always @ (posedge clk) begin
        if (reset == 1) begin
            cursor1 <= -1;
            cursor2 <= -1;
            cursor3 <= -1;
        end
        else begin
            cursor1 <= cursor;
            cursor2 <= cursor1;
            cursor3 <= cursor2;
        end
	end

	// state to indicate which row of ram is written in current cycle
	reg state_ram1, state_ram2, state_ram3;

	always @ (posedge wren, posedge reset) begin
        if (reset == 1) begin
			state_ram1 <= 1;
			state_ram2 <= 0;
			state_ram3 <= 0;
        end
        else begin
			state_ram1 <= state_ram3;
			state_ram2 <= state_ram1;
			state_ram3 <= state_ram2;
        end
	end

	// writing enable signal for each 3 row
	wire wren_row1, wren_row2, wren_row3;

	assign wren_row1 = (wren == 1) & (state_ram1);
	assign wren_row2 = (wren == 1) & (state_ram2);
	assign wren_row3 = (wren == 1) & (state_ram3);

	// flag to determine the middle px
	wire flag_cursor_mid;

	assign flag_cursor_mid = (cursor > 0 ) & (cursor < BLOCK_LENGTH );



	// address of each ram
	wire [7:0] addr11, addr12, addr13,
			   addr21, addr22, addr23,
			   addr31, addr32, addr33;

	assign addr11 = ( wren==1 & wren_row1==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] - 1 : -1;
	assign addr12 = ( wren==1 & wren_row1==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] + 0 : -1;
	assign addr13 = ( wren==1 & wren_row1==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] + 1 : -1;
	assign addr21 = ( wren==1 & wren_row2==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] - 1 : -1;
	assign addr22 = ( wren==1 & wren_row2==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] + 0 : -1;
	assign addr23 = ( wren==1 & wren_row2==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] + 1 : -1;
	assign addr31 = ( wren==1 & wren_row3==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] - 1 : -1;
	assign addr32 = ( wren==1 & wren_row3==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] + 0 : -1;
	assign addr33 = ( wren==1 & wren_row3==1 )? cursor[7:0] : ( flag_cursor_mid )? cursor[7:0] + 1 : -1;

	// manage the correct row of data
	wire [15:0] q11, q12, q13,
				q21, q22, q23,
				q31, q32, q33;

	wire [15:0] d11, d12, d13,
				d21, d22, d23,
				d31, d32, d33;


	assign d11 = (state_ram3 == 1)? q11 : (state_ram1 == 1)? q21 : q31;
	assign d12 = (state_ram3 == 1)? q12 : (state_ram1 == 1)? q22 : q32;
	assign d13 = (state_ram3 == 1)? q13 : (state_ram1 == 1)? q23 : q33;
	assign d21 = (state_ram3 == 1)? q21 : (state_ram1 == 1)? q31 : q11;
	assign d22 = (state_ram3 == 1)? q22 : (state_ram1 == 1)? q32 : q12;
	assign d23 = (state_ram3 == 1)? q23 : (state_ram1 == 1)? q33 : q13;
	assign d31 = (state_ram3 == 1)? q31 : (state_ram1 == 1)? q11 : q21;
	assign d32 = (state_ram3 == 1)? q32 : (state_ram1 == 1)? q12 : q22;
	assign d33 = (state_ram3 == 1)? q33 : (state_ram1 == 1)? q13 : q23;


	// filter color data
	wire [4:0] f_11_r, f_12_r, f_13_r,
				 f_21_r, f_22_r, f_23_r,
				 f_31_r, f_32_r, f_33_r;

	wire [5:0] f_11_g, f_12_g, f_13_g,
				f_21_g, f_22_g, f_23_g,
				f_31_g, f_32_g, f_33_g;

	wire [4:0] f_11_b, f_12_b, f_13_b,
			   f_21_b, f_22_b, f_23_b,
			   f_31_b, f_32_b, f_33_b;

	assign f_11_r = d11[15:11];
	assign f_12_r = d12[15:11];
	assign f_13_r = d13[15:11];
	assign f_21_r = d21[15:11];
	assign f_22_r = d22[15:11];
	assign f_23_r = d23[15:11];
	assign f_31_r = d31[15:11];
	assign f_32_r = d32[15:11];
	assign f_33_r = d33[15:11];

	assign f_11_g = d11[10:5];
	assign f_12_g = d12[10:5];
	assign f_13_g = d13[10:5];
	assign f_21_g = d21[10:5];
	assign f_22_g = d22[10:5];
	assign f_23_g = d23[10:5];
	assign f_31_g = d31[10:5];
	assign f_32_g = d32[10:5];
	assign f_33_g = d33[10:5];

	assign f_11_b = d11[4:0];
	assign f_12_b = d12[4:0];
	assign f_13_b = d13[4:0];
	assign f_21_b = d21[4:0];
	assign f_22_b = d22[4:0];
	assign f_23_b = d23[4:0];
	assign f_31_b = d31[4:0];
	assign f_32_b = d32[4:0];
	assign f_33_b = d33[4:0];

	// filtered RGB

	wire [4:0] filtered_r;
	wire [5:0] filtered_g;
	wire [4:0] filtered_b;

	assign filtered_r = f_22_r ;

	assign filtered_g = f_22_g ;

	assign filtered_b = f_22_b;

	// final filtered data
	wire [15:0] filtered_data;

	assign filtered_data[15:11] = filtered_r[4:0];
	assign filtered_data[10:5] = filtered_g[5:0];
	assign filtered_data[4:0] = filtered_b[4:0];

	// output data
	assign d_out = (flag_cursor_mid)? filtered_data : 0;

	// data ready signal for write_filter_tb
	assign d_rdy = (wren == 0) & ((cursor == cursor3));

	// connection of wire and ram
    ram ram11
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr11),
        .wren(wren_row1),

		// data
        .data(d_in),
        .q(q11)
    );

    ram ram12
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr12),
        .wren(wren_row1),

		// data
        .data(d_in),
        .q(q12)
    );

    ram ram13
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr13),
        .wren(wren_row1),

		// data
        .data(d_in),
        .q(q13)
    );

    ram ram21
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr21),
        .wren(wren_row2),

		// data
        .data(d_in),
        .q(q21)
    );

    ram ram22
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr22),
        .wren(wren_row2),

		// data
        .data(d_in),
        .q(q22)
    );

    ram ram23
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr23),
        .wren(wren_row2),

		// data
        .data(d_in),
        .q(q23)
    );

    ram ram31
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr31),
        .wren(wren_row3),

		// data
        .data(d_in),
        .q(q31)
    );

    ram ram32
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr32),
        .wren(wren_row3),

		// data
        .data(d_in),
        .q(q32)
    );

    ram ram33
	(
		// sys
        .clock(clk),

		// control signal
        .address(addr33),
        .wren(wren_row3),

		// data
        .data(d_in),
        .q(q33)
    );


endmodule
