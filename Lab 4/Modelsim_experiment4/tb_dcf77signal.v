// ------------------------------------------------------------------------- --
// Title         : DCF77-Decoder testbench
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : timeAndDateClock.v
// Author        : Cecilia Hoeffler
// Company       : IDS RWTH Aachen 
// Created       : 2018/07/19
// ------------------------------------------------------------------------- --
// Description   : Tests the DCF77 decoder module by creating a valid and an invalid dcf signal
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/07/19  1.0      CH      Created
// 2018/09/28  1.1      TS      Bugfixes
// ------------------------------------------------------------------------- --

//`timescale 1 ps / 1 ps
module tb_dcf77signal(
);


reg clock;
reg rst;
reg dcf;
reg dcf_select;

wire[43:0]  timeAndDate_out;
wire        data_valid,dcf_value;

wire        CLK_ENA_HZ_async;
wire        CLK_ENA_HZ_sync;
wire        MINUTE_START;

 //----------------------------------------------------------
 // create a clock (f=500Ghz in sim time)
 // 1ns in simulation = 1s in reality
 always
 #1 clock = ~clock; 
 //-----------------------------------------------------------
 // initial blocks are sequential and start at time 0
 initial
 begin
 $display($time, " << Starting the Simulation >>");
 clock = 1'b0;
 rst = 1'b0;
 dcf = 1'b1;
 dcf_select = 1'b1;
 #50 rst = 1'b1;
#4100 dcf= 1'b0; // wait 4000ps until first data is received
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#1800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#800 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0; 
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#100 dcf= 1'b1;// 0
#900 dcf= 1'b0;
#200 dcf= 1'b1;// 1
#1800 dcf= 1'b0;
 end
 
 
 // Parameters of DCF clock generator:
 //   frequency (default: 10000000): frequency of incoming signal. In our case: 500Ghz -> 500Hz in relation to the simulated dcf signal
 //   fir_len (default: 32): FIR filter length
 //   thresh_lo (default: 14): Threshold for decoding a '0' (if less than 14 '1's are sampled at a certain time, a '0' is read. The '1's are considered noise.)
 //   thresh_hi (default: 16): Threshold for decoding a '1' (if more than 16 '1's are sampled at a certain time, a '1' is read. If exactly between thresh_lo and thresh_hi, retain previous value)
 //   timestep (default: 128): Downsampling of original DCF signal. Not necessary here, as global simulated clock is slower in relation to the simulated dcf signal than the real clock)
 GenClockDCF #(500, 32, 14, 16, 1) genClockDCF_inst(
  .clk(clock), // I
  .nReset(rst), // I 
  .DCF_SELECT_in(dcf_select), // I
  .DCF_SIGNAL_in(dcf), // I
  .CLK_ENA_HZ_async_out(CLK_ENA_HZ_async), // O
  .CLK_ENA_HZ_sync_out(CLK_ENA_HZ_sync), // O
  .MINUTE_START_out(MINUTE_START)); // O
                   
 dcf77_decoder DUT(
  .clk(clock), // I
  .nReset(rst), // I  
  .dcf_Signal_in(dcf), // I
  .clk_en_1hz(CLK_ENA_HZ_sync), // I
  .minute_start_in(MINUTE_START), // I
  .timeAndDate_out(timeAndDate_out), // O 
  .data_valid(data_valid), // O 
  .dcf_value(dcf_value)); // O
endmodule