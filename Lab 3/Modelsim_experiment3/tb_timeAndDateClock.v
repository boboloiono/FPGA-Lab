`timescale 1ns / 1ps

module tb_timeAndDateClock;

// Inputs
reg clk;
reg clkEn1Hz;
reg nReset;
reg setTimeAndDate_in;
reg [43:0] timeAndDate_In;

// Outputs
wire [43:0] timeAndDate_Out;

// Instantiate the Unit Under Test (UUT)
timeAndDateClock DUT (
    .clk(clk),
    .clkEn1Hz(clkEn1Hz),
    .nReset(nReset),
    .setTimeAndDate_in(setTimeAndDate_in),
    .timeAndDate_In(timeAndDate_In),
    .timeAndDate_Out(timeAndDate_Out)
);

// Clock generation
initial begin
    clk = 0;
    forever #50 clk = ~clk; // 10MHz clock, 50ns period for each half cycle
end

// Testbench
initial begin
    // Initialize Inputs
    clkEn1Hz = 0;
    nReset = 0;
    setTimeAndDate_in = 0;
    timeAndDate_In = 44'b0;
    
    // Wait for global reset
    #100;
    nReset = 1; // Release reset
    #100;
    
    // Test case 1: Set initial time to 23:59:50 on Dec 31, 2099 (edge case for year increment)
    setTimeAndDate_in = 1;
    timeAndDate_In = {2'd0, 3'd1,			  // Week: 1 (Monday)
					  4'd9, 4'd9,			  // Year: 2099
                      1'b1, 4'd2,             // Month: 12 (December)
                      2'd3, 4'd1,             // Day: 31
                      2'd2, 4'd3,             // Hour: 23
                      3'd5, 4'd9,             // Minute: 59
                      3'd5, 4'd0};            // Second: 50
    #100;
    setTimeAndDate_in = 0;

    // Enable 1Hz clock signal for counting seconds
    clkEn1Hz = 1;

    // Wait and observe second increment
    #1000; // 1 second (simulates 1 second of time)

    // Test for minute and hour rollover
    #9000; // Wait for 9 more seconds, should bring to 00:00:00 on Jan 1, 2100

    // Test case 2: Set time to Feb 28, 2024 23:59:58 (Leap Year Test)
    setTimeAndDate_in = 1;
    timeAndDate_In = {2'd0, 3'd4,			  // Week: 4 (Tursday)
					  4'd2, 4'd4,             // Year: '24
                      1'b0, 4'd2,             // Month: 02 (February)
                      2'd2, 4'd8,             // Day: 28
                      2'd2, 4'd3,             // Hour: 23
                      3'd5, 4'd9,             // Minute: 59
                      3'd5, 4'd8};            // Second: 58
    #100;
    setTimeAndDate_in = 0;

    // Wait to observe leap year behavior on Feb 29
    #2000; // 2 seconds to go from 28 -> 29 Feb 2024, 00:00:00

    // Test case 3: Set time to Feb 28, 2023 23:59:58 (Non-Leap Year Test)
    setTimeAndDate_in = 1;
    timeAndDate_In = {2'd0, 3'd7,			  // Week: 7 (Sunday)
					  4'd2, 4'd3, 			  // Year: '23
                      1'b0, 4'd2,             // Month: 02 (February)
                      2'd2, 4'd8,             // Day: 28
                      2'd2, 4'd3,             // Hour: 23
                      3'd5, 4'd9,             // Minute: 59
                      3'd5, 4'd8};            // Second: 58
    #100;
    setTimeAndDate_in = 0;

    // Wait to observe non-leap year behavior (should skip Feb 29)
    #2000; // 2 seconds, should transition to Mar 1, 2023, 00:00:00

    // Test case 4: Reset the clock
    #100;
    nReset = 0; // Apply reset
    #100;
    nReset = 1; // Release reset

    // Observe reset behavior (time should be 0)
    #1000;

    // End simulation
    $finish;
end

endmodule