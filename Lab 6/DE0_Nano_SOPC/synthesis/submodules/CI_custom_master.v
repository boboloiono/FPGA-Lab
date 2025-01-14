/*

	Author:  Johnson Loh
	Last modified:  26/07/2018

	This modified CI-Template uses the Avalon MM Master Template to read
	blocks of data from the adressed memory of a static length using the
	Avalon Bus Iterface.

	For further information for the master templates (read_master/write_master):
	https://www.intel.com/content/www/us/en/programmable/support/support-resources/design-examples/intellectual-property/embedded/nios-ii/exm-avalon-mm.html

	TODO:
	- fix hardcoded parameter
	- documentation

*/

// dataa: base address of unfiltered image slice
// datab: base address of filtered image slice
// user_data_length: length of slice
// - FSM:
// 		- at start (start signal pulse 1 cyc) trigger read master only
// 		- when read master done set done pulse (m0_control_done pulse 1 cyc)
// 		- done signal from read master trigger write master
// 		- when write master done set done pulse (m1_control_done pulse 1 cyc)
// 		- final done pulse of custom master set after write master finished with processing (done signal pulse 1 cyc)
// - mem_cursor is increamented either from 0-719 (read case) or 0-239 (write case) for the relative address within image slice
// - wren of filter block is 1 for read state and 0 otherwise
// -

//`define USE_3_COLS // comment this line to load 240 px per ci custom master cycle

module CI_custom_master #(
    // read/write master parameter
`ifdef USE_3_COLS
    parameter BLOCK_LENGTH = 16'h02d0,  //720
`else
    parameter BLOCK_LENGTH = 16'hf0,    // 240
`endif

    // Read & Write Master parameter
    parameter DATAWIDTH       = 16,
    parameter BYTEENABLEWIDTH = 2,
    parameter ADDRESSWIDTH    = 32,
    parameter FIFODEPTH       = 32,
    parameter FIFODEPTH_LOG2  = 5,
    parameter FIFOUSEMEMORY   = 0,

    parameter LATENCY = 0
) (
    // system
    input reset,
    input clk,

    // custom instruction
    input clk_custom,
    input rst_custom,
    input clk_en,
    input [31:0] dataa,
    input [31:0] datab,
    input start,
    output [31:0] result,
    output wire done,

    // avalon mm master
    output wire [31:0] master_address,
    output wire master_read,
    output wire master_write,
    output wire [1:0] master_byteenable,
    input [15:0] master_readdata,
    input master_readdatavalid,
    output wire [15:0] master_writedata,
    output wire [2:0] master_burstcount,
    input master_waitrequest
);

  /////////////////////// reg & wire

  // m0: read master
  wire m0_control_done;
  wire [15:0] m0_user_buffer_output_data;
  wire m0_user_data_available;
  wire m0_user_read_buffer;

  wire [31:0] m0_master_address;
  wire m0_master_read;
  wire m0_master_write;
  wire [1:0] m0_master_byteenable;
  wire [15:0] m0_master_readdata;
  wire m0_master_readdatavalid;
  wire [15:0] m0_master_writedata;
  wire [2:0] m0_master_burstcount;
  wire m0_master_waitrequest;

  // m1: write_master
  wire m1_control_go;
  wire m1_control_done;
  wire m1_user_buffer_full;
  wire m1_user_write_buffer;
  wire [15:0] m1_user_buffer_input_data;

  wire [31:0] m1_master_address;
  wire m1_master_read;
  wire m1_master_write;
  wire [1:0] m1_master_byteenable;
  wire [15:0] m1_master_readdata;
  wire m1_master_readdatavalid;
  wire [15:0] m1_master_writedata;
  wire [2:0] m1_master_burstcount;
  wire m1_master_waitrequest;

  // f0: filter control logic
  wire f0_wren;
  wire f0_d_rdy;

  // read control logic
  wire rdfifo_done;
  wire inc_read_matrix_cursor;
  reg [9:0] read_matrix_cursor;

  // write control logic
  wire inc_write_matrix_cursor;
  reg [9:0] write_matrix_cursor;

  // misc
  wire [31:0] user_data_length;
  wire [9:0] mem_cursor;

  // fsm
  reg [2:0] state;
  reg [2:0] state_nxt;

  //debug
  reg [15:0] data_in;
  reg [15:0] data_out;
  wire [15:0] data_out_w;


  //////////////////////// state FSM parameter
  parameter STA_IDLE = 3'b000;  // 0: idle state
  parameter STA_READ = 3'b001;  // 1: read state
  parameter STA_READ_DONE = 3'b010;  // 2: read done state
  parameter STA_WRITE = 3'b011;  // 3: write state
  parameter STA_WRITE_DONE = 3'b100;  // 4: write done state

  //////////////////////// read/write master modules instantiation
  // latency_aware_read_master #(
  read_master #(
      .DATAWIDTH(DATAWIDTH),
      .BYTEENABLEWIDTH(BYTEENABLEWIDTH),
      .ADDRESSWIDTH(ADDRESSWIDTH),
      .FIFODEPTH(FIFODEPTH),
      .FIFODEPTH_LOG2(FIFODEPTH_LOG2),
      .FIFOUSEMEMORY(FIFOUSEMEMORY)
  ) m0 (
      .clk  (clk),
      .reset(reset),

      // control inputs and outputs
      .control_fixed_location(1'b0),
      .control_read_base(dataa),
      .control_read_length(user_data_length),
      .control_go(start),
      .control_done(m0_control_done),
      .control_early_done(),

      // user logic inputs and outputs
      .user_read_buffer(m0_user_read_buffer),
      .user_buffer_data(m0_user_buffer_output_data),
      .user_data_available(m0_user_data_available),

      // master inputs and outputs
      .master_address(m0_master_address),
      .master_read(m0_master_read),
      .master_byteenable(m0_master_byteenable[1:0]),
      .master_readdata(m0_master_readdata),
      .master_readdatavalid(m0_master_readdatavalid),
      .master_waitrequest(m0_master_waitrequest)
  );

  write_master #(
      .DATAWIDTH(DATAWIDTH),
      .BYTEENABLEWIDTH(BYTEENABLEWIDTH),
      .ADDRESSWIDTH(ADDRESSWIDTH),
      .FIFODEPTH(FIFODEPTH),
      .FIFODEPTH_LOG2(FIFODEPTH_LOG2),
      .FIFOUSEMEMORY(FIFOUSEMEMORY)
  ) m1 (
      .clk  (clk),
      .reset(reset),

      // control inputs and outputs
      .control_fixed_location(1'b0),
`ifdef USE_3_COLS
      .control_write_base((datab + 2 * 240)),
      .control_write_length((user_data_length - 2 * 480)),
`else
      .control_write_base((datab)),
      .control_write_length((user_data_length)),
`endif
      .control_go(m1_control_go),
      .control_done(m1_control_done),

      // user logic inputs and outputs
      .user_write_buffer(m1_user_write_buffer),
      .user_buffer_data (m1_user_buffer_input_data),
      .user_buffer_full (m1_user_buffer_full),

      // master inputs and outputs
      .master_address(m1_master_address),
      .master_write(m1_master_write),
      .master_byteenable(m1_master_byteenable[1:0]),
      .master_writedata(m1_master_writedata),
      .master_waitrequest(m1_master_waitrequest)
  );

  //////////////////////// filter module instantiation
  filter_3x3_240px #(
      .BLOCK_LENGTH(BLOCK_LENGTH)
  ) f0 (
      .clk  (clk),
      .reset(reset),

      .d_in (data_in),
      .d_out(data_out_w),

      .wren  (f0_wren),
      .d_rdy (f0_d_rdy),
      .cursor(mem_cursor)
  );

  /////////////////////// read logic
  // read_matrix_cursor
  // counter to increment the cursor from zero to BLOCK_LENGTH (720) in order to adress the On-Chip RAM in
  // read mode (reading from SDRAM)
  always @(posedge clk) begin
    if (reset == 1) read_matrix_cursor <= 0;
    else if (state == STA_IDLE) read_matrix_cursor <= 0;
    else if (state == STA_READ)
      if (inc_read_matrix_cursor == 1) read_matrix_cursor <= read_matrix_cursor + 1;
      else read_matrix_cursor <= read_matrix_cursor;
  end

  // read matrix
  always @(posedge clk) begin
    if (state == STA_READ) if (inc_read_matrix_cursor == 1) data_in <= m0_user_buffer_output_data;
  end

  /////////////////////// write logic

  // write_matrix_cursor
  // counter to increment the cursor from zero to BLOCK_LENGTH (720) in order to adress the On-Chip RAM in
  // write mode (writing to SDRAM)
  always @(posedge clk) begin
    if (reset == 1) write_matrix_cursor <= BLOCK_LENGTH;
    else if (state == STA_READ_DONE) write_matrix_cursor <= 0;
    else if (state == STA_WRITE)
      if (inc_write_matrix_cursor == 1) write_matrix_cursor <= write_matrix_cursor + 1;
      else write_matrix_cursor <= write_matrix_cursor;
    else write_matrix_cursor <= BLOCK_LENGTH;
  end

  /////////////////////// state FSM
  // state machine to control flow from and to SDRAM
  // -  STA_IDLE: idle state in which nothing happens
  // -  STA_READ: state in which reading from SDRAM in happening
  // -  STA_READ_DONE: state in which reading from SDRAM is finished (one cycle)
  // -  STA_WRITE: state in which writing from SDRAM in happening
  // -  STA_READ_DONE: state in which writing from SDRAM is finished (one cycle)

  always @(posedge clk) begin
    if (reset == 1) state <= STA_IDLE;
    else state <= state_nxt;
  end

  always @(*) begin
    case (state)
      STA_IDLE: begin
        if (start == 1) state_nxt = STA_READ;
        else state_nxt = STA_IDLE;
      end
      STA_READ: begin
        if (rdfifo_done == 1) state_nxt = STA_READ_DONE;
        else state_nxt = STA_READ;
      end
      STA_READ_DONE: begin
        state_nxt = STA_WRITE;
      end
      STA_WRITE: begin
        if (m1_control_done == 1) state_nxt = STA_WRITE_DONE;
        else state_nxt = STA_WRITE;
      end
      STA_WRITE_DONE: begin
        state_nxt = STA_IDLE;
      end

      default: state_nxt = STA_IDLE;
    endcase  // state
  end

  always @(*) begin
    data_out = data_out_w;
  end

  assign m1_user_buffer_input_data = data_out;

  /////////////////////// filter control signals
  assign f0_wren = (state == STA_READ);

  /////////////////////// read control signals
  assign inc_read_matrix_cursor = (read_matrix_cursor < BLOCK_LENGTH) & m0_user_data_available;
  assign m0_user_read_buffer = inc_read_matrix_cursor;
  assign rdfifo_done = (read_matrix_cursor == BLOCK_LENGTH) & m0_control_done;

  /////////////////////// write control signals
  assign m1_control_go = (state == STA_READ_DONE);
  assign inc_write_matrix_cursor = (write_matrix_cursor < BLOCK_LENGTH) & (m1_user_buffer_full == 0) & (f0_d_rdy == 1);
  assign m1_user_write_buffer = inc_write_matrix_cursor;

  /////////////////////// custom instruction control signals
  assign done = (state == STA_WRITE_DONE);
  assign result = data_out;  // TODO: use to set error bit

  //////////////////////// master bus mux logic
  assign master_address = (state == STA_WRITE | state == STA_READ_DONE) ? m1_master_address : m0_master_address;
  assign master_read = (state == STA_WRITE | state == STA_READ_DONE) ? m1_master_read : m0_master_read;
  assign master_write = (state == STA_WRITE | state == STA_READ_DONE) ? m1_master_write : m0_master_write;
  assign master_byteenable = (state == STA_WRITE | state == STA_READ_DONE) ? m1_master_byteenable : m0_master_byteenable;
  assign master_writedata = (state == STA_WRITE | state == STA_READ_DONE) ? m1_master_writedata : m0_master_writedata;
  assign master_burstcount = (state == STA_WRITE | state == STA_READ_DONE) ? m1_master_burstcount : m0_master_burstcount;

  assign m0_master_readdata = master_readdata;
  assign m0_master_readdatavalid = master_readdatavalid;
  assign m0_master_waitrequest = master_waitrequest;
  assign m1_master_readdata = master_readdata;
  assign m1_master_readdatavalid = master_readdatavalid;
  assign m1_master_waitrequest = master_waitrequest;

  //////////////////////// misc
  assign mem_cursor = (state == STA_WRITE | state == STA_READ_DONE) ? write_matrix_cursor : read_matrix_cursor;
  assign user_data_length = 2 * BLOCK_LENGTH;

endmodule
