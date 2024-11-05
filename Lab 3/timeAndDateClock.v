// ------------------------------------------------------------------------- --
// Title         : Clockwork
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : timeAndDateClock.v
// Author        : Shutao Zhang
// Company       : IDS RWTH Aachen 
// Created       : 2018/08/16
// ------------------------------------------------------------------------- --
// Description   : Clockwork for a DCF77 radio-controlled clock
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/08/16  1.0      SH      Created
// 2018/09/20  1.1      TS      Clean up, comments
// ------------------------------------------------------------------------- --

module timeAndDateClock(input clk,                // global 10Mhz clock
                        input clkEn1Hz,           // 1Hz clock
                        input nReset,             // asynchronous reset (active low)  
                        input setTimeAndDate_in,  
                        input[43:0] timeAndDate_In,     
                        output reg[43:0] timeAndDate_Out);   

// ---------- YOUR CODE HERE ---------- 

// Extracting individual time fields from input/output
wire [3:0] sec_lo = timeAndDate_Out[3:0];    // seconds, low digit
wire [2:0] sec_hi = timeAndDate_Out[6:4];    // seconds, high digit
wire [3:0] min_lo = timeAndDate_Out[10:7];   // minutes, low digit
wire [2:0] min_hi = timeAndDate_Out[13:11];  // minutes, high digit
wire [3:0] hr_lo  = timeAndDate_Out[17:14];  // hours, low digit
wire [1:0] hr_hi  = timeAndDate_Out[19:18];  // hours, high digit
wire [3:0] day_lo = timeAndDate_Out[23:20];  // day, low digit
wire [1:0] day_hi = timeAndDate_Out[25:24];  // day, high digit
wire [3:0] month_lo = timeAndDate_Out[29:26]; // month, low digit
wire [0:0] month_hi = timeAndDate_Out[30];    // month, high digit
wire [3:0] year_lo = timeAndDate_Out[34:31];  // year, low digit
wire [3:0] year_hi = timeAndDate_Out[38:35];  // year, high digit
wire [2:0] week_day = timeAndDate_Out[41:39]; // weekday
wire [1:0] timezone = timeAndDate_Out[43:42]; // timezone 


// Leap year?
wire [7:0] year = {year_hi, year_lo} % 4;
wire isLeapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);

always @(posedge clk, negedge nReset) begin
	if(!nReset) begin
		timeAndDate_Out <= 44'b0;
	end else if(!setTimeAndDate_in) begin
			timeAndDate_Out <= timeAndDate_In; // Load time and date from input
	end else if(clkEn1Hz) begin	// add data by every second
		// min + 1 when (second == 59)
		if(sec_lo == 4'd9) begin
			timeAndDate_Out[3:0] <= 4'd0;
			if(sec_hi == 3'd5) begin
				timeAndDate_Out[6:4] <= 3'd0;
				
				// hour + 1 when (min == 59)
				if(min_lo == 4'd9) begin
					timeAndDate_Out[10:7] <= 4'd0;
					if(min_hi == 3'd5) begin
						timeAndDate_Out[13:11] <= 3'd0;
						
						// reset hours when (hour == 23) or hour_high + 1 when (hour_low == 9)
						if (hr_lo == 4'd9 || (hr_hi == 2'd2 && hr_lo == 4'd3)) begin
                            timeAndDate_Out[17:14] <= 4'd0;
                            if (hr_hi == 2'd2) begin
                                timeAndDate_Out[19:18] <= 2'd0; // Reset hours to 00 after 23
								
								// Clockwork for days
								if ((day_lo == 4'd9 && day_hi == 2'd0)|| (day_lo == 4'd9 && day_hi == 2'd1) || ((day_lo == 4'd9 && day_hi == 2'd2) && !(month_lo == 4'd2 && isLeapYear)) ) begin
									timeAndDate_Out[23:20] <= 4'd0;
									timeAndDate_Out[25:24] <= day_hi + 2'd1;
								end else begin
									timeAndDate_Out[23:20] <= day_lo + 4'd1;
									timeAndDate_Out[41:39] <= (week_day % 7 == 0) ? 3'd1 : week_day + 1'b1;
								end
								if((day_lo == 4'd1 && day_hi == 2'd3 && !(day_hi == 2'd0 && month_lo == 4'd2)) || // months of 31 days
								(day_lo == 4'd9 && day_hi == 2'd2 && month_lo == 4'd2 && isLeapYear) || // Feb : leap year (29 days)
								(day_lo == 4'd8 && day_hi == 2'd2 && month_lo == 4'd2 && !isLeapYear) || // Feb: non leap year (28 days)
								(day_lo == 4'd0 && day_hi == 2'd3 && (month_lo == 4'd4 || month_lo == 4'd6 || month_lo == 4'd9 || (month_lo == 4'd1 && month_hi == 2'd1)))) begin // months of 30 days
									timeAndDate_Out[23:20] <= 4'd1;
									timeAndDate_Out[25:24] <= 2'd0;
									if (month_hi == 1'd1 && month_lo == 4'd2) begin // Dec(12) -> Jan (1)
										timeAndDate_Out[30] <= 1'b0;
										timeAndDate_Out[29:26] <= 4'd1;
										if (year_lo == 4'd9) begin
											timeAndDate_Out[34:31] <= 4'd0;
											if(year_hi == 4'd9) begin
												timeAndDate_Out[38:35] <= 4'd0;
											end else begin
												timeAndDate_Out[38:35] <= year_hi + 4'd1;
											end
										end else begin
											timeAndDate_Out[34:31] <= year_lo + 4'd1;
										end
									end else if (month_lo == 4'd9) begin
										timeAndDate_Out[30] <= month_hi + 1'd1;
										timeAndDate_Out[29:26] <= 4'd0;
									end else begin
										timeAndDate_Out[29:26] <= month_lo + 4'd1;
									end
								end
							end else begin
                                timeAndDate_Out[19:18] <= hr_hi + 2'd1;
                            end
                        end else begin
                            timeAndDate_Out[17:14] <= hr_lo + 4'd1;
                        end
					end else begin
						timeAndDate_Out[13:11] <= min_hi + 3'd1;
					end
				end else begin
					timeAndDate_Out[10:7] <= min_lo + 4'd1;
				end
			end else begin
				timeAndDate_Out[6:4] <= sec_hi + 3'd1;
			end
		end else begin
			timeAndDate_Out[3:0] <= sec_lo + 4'd1;
		end
		
	end
end


endmodule
