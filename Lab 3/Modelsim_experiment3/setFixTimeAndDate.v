// ------------------------------------------------------------------------- --
// Title         : Output of a fixed time and date
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : setFixTimeAndDate.v
// Author        : Shutao Zhang
// Company       : IDS RWTH Aachen 
// Created       : 2018/08/16
// ------------------------------------------------------------------------- --
// Description   : This module outputs the timeAndDate vector for Tuesday, 
//                 2019/07/31, 23:59:45
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/08/16  1.0      SH      Created
// 2018/09/20  1.1      TS      Clean up, comments
// ------------------------------------------------------------------------- --
module setFixTimeAndDate(output reg[43:0] timeAndDate_Out);

initial
begin 
  timeAndDate_Out[3:0]   <= 4'b0101;   // lower digit of second is 5
  timeAndDate_Out[6:4]   <= 3'b100;    // higher digit of second is 4
  timeAndDate_Out[10:7]  <= 4'b1001;   // lower digit of minute is 9
  timeAndDate_Out[13:11] <= 3'b101;    // higher digit of minute is 5
  timeAndDate_Out[17:14] <= 4'b0011;   // lower digit of hour is 3
  timeAndDate_Out[19:18] <= 2'b10;     // higher digit of hour is 2
  timeAndDate_Out[23:20] <= 4'b0001;   // lower digit of day is 1
  timeAndDate_Out[25:24] <= 2'b11;     // higher digit of day is 3
  timeAndDate_Out[29:26] <= 4'b0111;   // lower digit of month is 7
  timeAndDate_Out[30]    <= 1'b0;      // higher digit of month is 0
  timeAndDate_Out[34:31] <= 4'b1001;   // lower digit of year is 9
  timeAndDate_Out[38:35] <= 4'b0001;   // higher digit of year is 1
  timeAndDate_Out[41:39] <= 3'b010;    // weekday is Tuesday
  timeAndDate_Out[43:42] <= 2'b00;     // timezone is 0
end

endmodule