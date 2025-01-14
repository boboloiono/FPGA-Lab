/*
	Author:  Yee Yang Tan
	Last modified:  07/08/2020 by Cecilia Latotzke
*/

module filter_3x3_720px
#(
	 parameter BLOCK_LENGTH = 720,

    // weight of each pixel, change these parameters to make difference effect of filter
	// |WA3|WB3|WA3|
	// |WB3|WA1|WB3|
	// |WA3|WB3|WA3|
	parameter WA3 = 0,
			  WB3 = -1,
			  WA1 = 4,

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
	wire wren1, wren2, wren3;

	assign wren1 = (wren == 1) & (cursor < 240);
	assign wren2 = (wren == 1) & (cursor < 480) & (cursor > 239);
	assign wren3 = (wren == 1) & (cursor < 720) & (cursor > 479);

	// flag to determine the middle px
	wire flag_cursor_mid;

	assign flag_cursor_mid = (cursor > 0) & (cursor < 240);

	// address of each ram
	wire [7:0] addr11, addr12, addr13,
			   addr21, addr22, addr23,
			   addr31, addr32, addr33;

    // If the ram is not used, the address value of the ram is 0xFF
	assign addr11 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 - 1 : (wren1 == 1)? cursor % 240 : 8'hFF;
	assign addr12 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 0 : (wren1 == 1)? cursor % 240 : 8'hFF;
	assign addr13 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 1 : (wren1 == 1)? cursor % 240 : 8'hFF;
	assign addr21 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 - 1 : (wren2 == 1)? cursor % 240 : 8'hFF;
	assign addr22 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 0 : (wren2 == 1)? cursor % 240 : 8'hFF;
	assign addr23 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 1 : (wren2 == 1)? cursor % 240 : 8'hFF;
	assign addr31 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 - 1 : (wren3 == 1)? cursor % 240 : 8'hFF;
	assign addr32 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 0 : (wren3 == 1)? cursor % 240 : 8'hFF;
	assign addr33 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 1 : (wren3 == 1)? cursor % 240 : 8'hFF;

	// memory output of ram
	wire [15:0] q11, q12, q13,
				q21, q22, q23,
				q31, q32, q33;

	// filter color data
	wire [8:0]              f_11_r, f_12_r, f_13_r,
				f_21_r, f_22_r, f_23_r,
				f_31_r, f_32_r, f_33_r;

	wire [9:0]              f_11_g, f_12_g, f_13_g,
				f_21_g, f_22_g, f_23_g,
				f_31_g, f_32_g, f_33_g;

	wire [8:0]         	f_11_b, f_12_b, f_13_b,
			        f_21_b, f_22_b, f_23_b,
			   	f_31_b, f_32_b, f_33_b;

	assign f_11_r = q11[15:11];
	assign f_12_r = q12[15:11];
	assign f_13_r = q13[15:11];
	assign f_21_r = q21[15:11];
	assign f_22_r = q22[15:11];
	assign f_23_r = q23[15:11];
	assign f_31_r = q31[15:11];
	assign f_32_r = q32[15:11];
	assign f_33_r = q33[15:11];

	assign f_11_g = q11[10:5];
	assign f_12_g = q12[10:5];
	assign f_13_g = q13[10:5];
	assign f_21_g = q21[10:5];
	assign f_22_g = q22[10:5];
	assign f_23_g = q23[10:5];
	assign f_31_g = q31[10:5];
	assign f_32_g = q32[10:5];
	assign f_33_g = q33[10:5];

	assign f_11_b = q11[4:0];
	assign f_12_b = q12[4:0];
	assign f_13_b = q13[4:0];
	assign f_21_b = q21[4:0];
	assign f_22_b = q22[4:0];
	assign f_23_b = q23[4:0];
	assign f_31_b = q31[4:0];
	assign f_32_b = q32[4:0];
	assign f_33_b = q33[4:0];


	// filtered RGB
	//implement filter here

	wire [10:0] filtered_r, filtered_g, filtered_b;
	
	assign filtered_r = (f_11_r * WA3 + f_12_r *  WB3 + f_13_r * WA3 +
						 f_21_r * WB3 + f_22_r * WA1 + f_23_r * WB3 +
						 f_31_r * WA3 + f_32_r *  WB3 + f_33_r * WA3) / DIV;

	assign filtered_g = (f_11_g * WA3 + f_12_g * WB3 + f_13_g * WA3 +
						 f_21_g * WB3 + f_22_g * WA1 + f_23_g * WB3 +
						 f_31_g * WA3 + f_32_g * WB3 + f_33_g * WA3) / DIV;

	assign filtered_b = (f_11_b * WA3 + f_12_b *  WB3 + f_13_b * WA3 +
						 f_21_b * WB3 + f_22_b * WA1 + f_23_b * WB3 +
						 f_31_b * WA3 + f_32_b *  WB3 + f_33_b * WA3) / DIV; 	


	// final filtered data
	wire [15:0] filtered_data;

	assign filtered_data[15:11] = filtered_r[4:0];
	assign filtered_data[10:5] = filtered_g[5:0];
	assign filtered_data[4:0] = filtered_b[4:0];


	// output data
	assign d_out = (flag_cursor_mid)? filtered_data : 0;


	// data ready signal for write_filter_tb
	// assign d_rdy = (wren == 0) & ((cursor == cursor3)|~flag_cursor_mid);
	assign d_rdy = (wren == 0) & ((cursor == cursor3));


	// connection of wire and ram

    ram ram11(
        .address(addr11),
        .clock(clk),
        .data(d_in),
        .wren(wren1),
        .q(q11)
    );

    ram ram12(
        .address(addr12),
        .clock(clk),
        .data(d_in),
        .wren(wren1),
        .q(q12)
    );

    ram ram13(
        .address(addr13),
        .clock(clk),
        .data(d_in),
        .wren(wren1),
        .q(q13)
    );

    ram ram21(
        .address(addr21),
        .clock(clk),
        .data(d_in),
        .wren(wren2),
        .q(q21)
    );

    ram ram22(
        .address(addr22),
        .clock(clk),
        .data(d_in),
        .wren(wren2),
        .q(q22)
    );

    ram ram23(
        .address(addr23),
        .clock(clk),
        .data(d_in),
        .wren(wren2),
        .q(q23)
    );

    ram ram31(
        .address(addr31),
        .clock(clk),
        .data(d_in),
        .wren(wren3),
        .q(q31)
    );

    ram ram32(
        .address(addr32),
        .clock(clk),
        .data(d_in),
        .wren(wren3),
        .q(q32)
    );

    ram ram33(
        .address(addr33),
        .clock(clk),
        .data(d_in),
        .wren(wren3),
        .q(q33)
    );


endmodule