module filter_3x3_240px #(
    parameter BLOCK_LENGTH = 240,
    parameter FILTER_SIZE  = 3,

    // Filter weights
    parameter WA3 = 0,
    parameter WB3 = -1,
    parameter WA1 = 4,
    parameter DIV = 1
) (
    // System
    input reset,
    input clk,

    // IO
    input [15:0] d_in,
    output wire [15:0] d_out,

    // Control
    input wren,
    output wire d_rdy,
    input [9:0] cursor
);
  // Cursors for delay
  reg [9:0] cursor1, cursor2, cursor3;

  // Update cursors with delays
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      cursor1 <= 0;
      cursor2 <= 0;
      cursor3 <= 0;
    end else begin
      cursor1 <= cursor;
      cursor2 <= cursor1;
      cursor3 <= cursor2;
    end
  end

  reg [1:0] state;

  parameter STATE1 = 2'b00;
  parameter STATE2 = 2'b01;
  parameter STATE3 = 2'b10;

  always @(posedge wren or posedge reset) begin
    if (reset) begin
      state <= STATE1;
    end else begin
      case (state)
        STATE1:  state <= STATE2;
        STATE2:  state <= STATE3;
        STATE3:  state <= STATE1;
        default: state <= STATE1;
      endcase
    end
  end

  // writing enable signal for each 3 row
  wire wren1, wren2, wren3;

  assign wren1 = (wren == 1) & (state == STATE1);
  assign wren2 = (wren == 1) & (state == STATE2);
  assign wren3 = (wren == 1) & (state == STATE3);

  // flag to determine the middle px
  wire flag_cursor_mid;

  assign flag_cursor_mid = (cursor > 0) & (cursor < BLOCK_LENGTH);


  // address of each ram
  wire [7:0] addr11, addr12, addr13, addr21, addr22, addr23, addr31, addr32, addr33;

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
  wire [15:0] q11, q12, q13, q21, q22, q23, q31, q32, q33;

  // filter color data，RGB
  wire [8:0] f_11_r, f_12_r, f_13_r, f_21_r, f_22_r, f_23_r, f_31_r, f_32_r, f_33_r;

  wire [9:0] f_11_g, f_12_g, f_13_g, f_21_g, f_22_g, f_23_g, f_31_g, f_32_g, f_33_g;

  wire [8:0] f_11_b, f_12_b, f_13_b, f_21_b, f_22_b, f_23_b, f_31_b, f_32_b, f_33_b;

  wire [15:0] d11, d12, d13, d21, d22, d23, d31, d32, d33;

  assign d11 = (state == STATE3) ? q11 : (state == STATE1) ? q21 : q31;
  assign d12 = (state == STATE3) ? q12 : (state == STATE1) ? q22 : q32;
  assign d13 = (state == STATE3) ? q13 : (state == STATE1) ? q23 : q33;
  assign d21 = (state == STATE3) ? q21 : (state == STATE1) ? q31 : q11;
  assign d22 = (state == STATE3) ? q22 : (state == STATE1) ? q32 : q12;
  assign d23 = (state == STATE3) ? q23 : (state == STATE1) ? q33 : q13;
  assign d31 = (state == STATE3) ? q31 : (state == STATE1) ? q11 : q21;
  assign d32 = (state == STATE3) ? q32 : (state == STATE1) ? q12 : q22;
  assign d33 = (state == STATE3) ? q33 : (state == STATE1) ? q13 : q23;

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

  // Filtered RGB
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

  // RGB data after filtering
  wire [15:0] filtered_data;
  assign filtered_data[15:11] = filtered_r[4:0];
  assign filtered_data[10:5] = filtered_g[5:0];
  assign filtered_data[4:0] = filtered_b[4:0];

  // output data
  assign d_out = (flag_cursor_mid) ? filtered_data : 0;

  // data ready signal for write_filter_tb
  assign d_rdy = (wren == 0) & ((cursor == cursor3));

  // connection of wire and ram

  ram ram11 (
      .address(addr11),
      .clock(clk),
      .data(d_in),
      .wren(wren1),
      .q(q11)
  );

  ram ram12 (
      .address(addr12),
      .clock(clk),
      .data(d_in),
      .wren(wren1),
      .q(q12)
  );

  ram ram13 (
      .address(addr13),
      .clock(clk),
      .data(d_in),
      .wren(wren1),
      .q(q13)
  );

  ram ram21 (
      .address(addr21),
      .clock(clk),
      .data(d_in),
      .wren(wren2),
      .q(q21)
  );

  ram ram22 (
      .address(addr22),
      .clock(clk),
      .data(d_in),
      .wren(wren2),
      .q(q22)
  );

  ram ram23 (
      .address(addr23),
      .clock(clk),
      .data(d_in),
      .wren(wren2),
      .q(q23)
  );

  ram ram31 (
      .address(addr31),
      .clock(clk),
      .data(d_in),
      .wren(wren3),
      .q(q31)
  );

  ram ram32 (
      .address(addr32),
      .clock(clk),
      .data(d_in),
      .wren(wren3),
      .q(q32)
  );

  ram ram33 (
      .address(addr33),
      .clock(clk),
      .data(d_in),
      .wren(wren3),
      .q(q33)
  );
endmodule
