//without read function
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
// --------------------------------------------------------------------

module LT24_Controller(
	// global clock & reset
	clk,
	reset_n,
	
	// mm slave
	s_chipselect_n,
//	s_read,
	s_write_n,
//	s_readdata,
	s_writedata,
	s_address,
	
	lt24_cs,
	lt24_rs,//command/data
	lt24_rd,
	lt24_wr,
	lt24_data,
);
	
// global clock & reset
input	clk;
input	reset_n;

// mm slave
input		        s_chipselect_n;
//input			s_read;
input			s_write_n;
//output	reg [31:0]	s_readdata;
input	    [31:0]	s_writedata;
input	         	s_address;

output	   	lt24_cs;
output	   	lt24_rs;//command/data
output			lt24_rd;
output			lt24_wr;
output	      [15:0]	lt24_data;


assign lt24_cs = s_chipselect_n;
assign lt24_rs = s_address;
assign lt24_rd = 1'b1;
assign lt24_wr = s_write_n;
assign lt24_data = s_writedata[15:0];


endmodule
