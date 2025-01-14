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

  // Address and Write Enable for RAM
  wire [15:0] q1, q2, q3;
  wire wren1, wren2, wren3;
  wire [7:0] addr1, addr2, addr3;

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

  // If the ram is not used, the address value of the ram is 0xFF
  //assign addr1 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 1 : (wren1 == 1)? cursor % 240 : 8'hFF;
  //assign addr2 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 1 : (wren2 == 1)? cursor % 240 : 8'hFF;
  //assign addr3 = ((flag_cursor_mid == 1) & (wren == 0))? cursor % 240 + 1 : (wren3 == 1)? cursor % 240 : 8'hFF;
  assign addr1 = (wren == 0) ? cursor % 240 + 1 : (wren1 == 1) ? cursor % 240 + 1 : 8'hFF;
  assign addr2 = (wren == 0) ? cursor % 240 + 1 : (wren2 == 1) ? cursor % 240 + 1 : 8'hFF;
  assign addr3 = (wren == 0) ? cursor % 240 + 1 : (wren3 == 1) ? cursor % 240 + 1 : 8'hFF;

  reg [15:0] window[0:2][0:2];
  reg [9:0] pixel_count;

  localparam IDLE = 2'b00;
  localparam LOAD = 2'b01;
  localparam FILTER = 2'b10;
  localparam OUTPUT = 2'b11;

  reg [1:0] state, nxt_state;

  always @(posedge clk or posedge reset) begin
    if (reset) state <= IDLE;
    else state <= nxt_state;
  end

  always @(*) begin
    case (state)
      IDLE: begin
        if (wren) nxt_state = LOAD;
        else nxt_state = IDLE;
      end
      LOAD: begin
        if (pixel_count == BLOCK_LENGTH - 1) nxt_state = FILTER;
        else nxt_state = LOAD;
      end
      FILTER: begin
        if (pixel_count == BLOCK_LENGTH - 1) nxt_state = OUTPUT;
        else nxt_state = FILTER;
      end
      OUTPUT: begin
        nxt_state = IDLE;
      end
      default: nxt_state = IDLE;
    endcase
  end

  always @(posedge clk) begin
    if (state == LOAD && wren) begin
      write_ptr <= (write_ptr + 1) % BLOCK_LENGTH;
    end
  end

  always @(posedge clk) begin
    if (state == FILTER) begin
      window[0][0] <= window[0][1];
      window[0][1] <= window[0][2];
      window[0][2] <= q1;

      window[1][0] <= window[1][1];
      window[1][1] <= window[1][2];
      window[1][2] <= q2;

      window[2][0] <= window[2][1];
      window[2][1] <= window[2][2];
      window[2][2] <= q3;

      read_ptr <= (read_ptr + 1) % BLOCK_LENGTH;
    end
  end

  wire addr = (state == LOAD && wren) ? write_ptr : (state == FILTER) ? read_ptr : 8'hFF;


  always @(posedge clk or posedge reset) begin
    if (reset) pixel_count <= 0;
    else if (state == LOAD || start == FILTER) begin
      if (pixel_count < BLOCK_LENGTH - 1) pixel_count <= pixel_count + 1;
      else pixel_count <= 0;
    end
  end

  // RAM Instantiation
  ram ram1 (
      .address(addr1),
      .clock(clk),
      .data(d_in),
      .wren(wren1),
      .q(q1)
  );
  ram ram2 (
      .address(addr2),
      .clock(clk),
      .data(d_in),
      .wren(wren2),
      .q(q2)
  );
  ram ram3 (
      .address(addr3),
      .clock(clk),
      .data(d_in),
      .wren(wren3),
      .q(q3)
  );

  // Define 3x3 matrix of RGB weights
  wire [4:0] r00, r01, r02, r10, r11, r12, r20, r21, r22;
  wire [5:0] g00, g01, g02, g10, g11, g12, g20, g21, g22;
  wire [4:0] b00, b01, b02, b10, b11, b12, b20, b21, b22;

  assign {r00, g00, b00} = window[0][0];
  assign {r01, g01, b01} = window[0][1];
  assign {r02, g02, b02} = window[0][2];
  assign {r10, g10, b10} = window[1][0];
  assign {r11, g11, b11} = window[1][1];
  assign {r12, g12, b12} = window[1][2];
  assign {r20, g20, b20} = window[2][0];
  assign {r21, g21, b21} = window[2][1];
  assign {r22, g22, b22} = window[2][2];

  // Filtered RGB
  wire [10:0] filtered_r, filtered_g, filtered_b;
  assign filtered_r = (r00 * WA3 + r01 * WB3 + r02 * WA3 +
                         r10 * WB3 + r11 * WA1 + r12 * WB3 +
                         r20 * WA3 + r21 * WB3 + r22 * WA3) / DIV;

  assign filtered_g = (g00 * WA3 + g01 * WB3 + g02 * WA3 +
                         g10 * WB3 + g11 * WA1 + g12 * WB3 +
                         g20 * WA3 + g21 * WB3 + g22 * WA3) / DIV;

  assign filtered_b = (b00 * WA3 + b01 * WB3 + b02 * WA3 +
                         b10 * WB3 + b11 * WA1 + b12 * WB3 +
                         b20 * WA3 + b21 * WB3 + b22 * WA3) / DIV;

  // RGB data after filtering
  wire [15:0] filtered_data;
  assign filtered_data[15:11] = filtered_r[4:0];
  assign filtered_data[10:5] = filtered_g[5:0];
  assign filtered_data[4:0] = filtered_b[4:0];

  // Output signals
  assign d_out = (state == FILTER) ? filtered_data : 16'b0;
  //assign d_out = (flag_cursor_mid) ? filtered_data : 0;
  // assign d_rdy = (cursor == cursor3);
  assign d_rdy = (state == OUTPUT) & ((cursor == cursor3));

endmodule
/*
module filter_3x3_240px #(
    parameter BLOCK_LENGTH = 240,
    parameter FILTER_SIZE  = 3,

    // weight of each pixel, change these parameters to make difference effect of filter
    // |WA3|WB3|WA3|
    // |WB3|WA1|WB3|
    // |WA3|WB3|WA3|
    parameter WA3 = 0,
    parameter WB3 = -1,
    parameter WA1 = 4,
    parameter DIV = 1

) (
    // system
    input reset,
    input clk,

    // io
    input [15:0] d_in,
    output wire [15:0] d_out,

    // control
    input wren,
    output wire d_rdy,
    input [9:0] cursor
);

  //To Do: filter the input image
  //	- increase efficiency by eliminating redundancy
  //	- read each clock cycle a new line of pixels (except for the first three rows, since you need three rows to start filtering (because of the 3x3 filter))
  //	- keep the two already loaded lines for reuse
  //	- if necessary use an additional pointer to keep track of your first input pixel of the image
  //	- be aware that there could be timing issues:
  //	- synchronize your internal pointer with the custom master pointer
  //	- validate your design via SignalTap

  // 3 cursors delay, because of the ram required 3 clk cycle to output the data to 'q'
  reg [9:0] cursor1, cursor2, cursor3;

  reg [15:0] row0[0:BLOCK_LENGTH-1];
  reg [15:0] row1[0:BLOCK_LENGTH-1];
  reg [15:0] row2[0:BLOCK_LENGTH-1];

  always @(posedge clk) begin
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

  // update reg, every time only one pixel is added to reg
  integer i;
  always @(posedge clk) begin
    if (wren) begin
      // each data moves up once
      for (i = 0; i < BLOCK_LENGTH - 1; i = i + 1) begin
        row0[i] <= row0[i+1];
        row1[i] <= row1[i+1];
        row2[i] <= row2[i+1];
      end
      row0[BLOCK_LENGTH-1] <= row1[0];
      row1[BLOCK_LENGTH-1] <= row2[0];
      row2[BLOCK_LENGTH-1] <= d_in;
    end
  end

  // define 3x3 matrics of RGB weights
  wire [4:0] r00, r01, r02, r10, r11, r12, r20, r21, r22;
  wire [5:0] g00, g01, g02, g10, g11, g12, g20, g21, g22;
  wire [4:0] b00, b01, b02, b10, b11, b12, b20, b21, b22;

  assign {r00, g00, b00} = row0[cursor3];
  assign {r01, g01, b01} = row0[cursor3+1];
  assign {r02, g02, b02} = row0[cursor3+2];
  assign {r10, g10, b10} = row1[cursor3];
  assign {r11, g11, b11} = row1[cursor3+1];
  assign {r12, g12, b12} = row1[cursor3+2];
  assign {r20, g20, b20} = row2[cursor3];
  assign {r21, g21, b21} = row2[cursor3+1];
  assign {r22, g22, b22} = row2[cursor3+2];

  // filtered RGB
  wire [10:0] filtered_r, filtered_g, filtered_b;

  assign filtered_r = (r00 * WA3 + r01 * WB3 + r02 * WA3 +
                         r10 * WB3 + r11 * WA1 + r12 * WB3 +
                         r20 * WA3 + r21 * WB3 + r22 * WA3) / DIV;

  assign filtered_g = (g00 * WA3 + g01 * WB3 + g02 * WA3 +
                         g10 * WB3 + g11 * WA1 + g12 * WB3 +
                         g20 * WA3 + g21 * WB3 + g22 * WA3) / DIV;

  assign filtered_b = (b00 * WA3 + b01 * WB3 + b02 * WA3 +
                         b10 * WB3 + b11 * WA1 + b12 * WB3 +
                         b20 * WA3 + b21 * WB3 + b22 * WA3) / DIV;

  // RGB data after filtered
  wire [15:0] filtered_data;
  assign filtered_data[15:11] = filtered_r[4:0];
  assign filtered_data[10:5] = filtered_g[5:0];
  assign filtered_data[4:0] = filtered_b[4:0];

  // data ready signal for write_filter_tb
  assign d_out = filtered_data;
  assign d_rdy = (wren == 0) & ((cursor == cursor3));

endmodule
*/
