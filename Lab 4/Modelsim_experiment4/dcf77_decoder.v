// ------------------------------------------------------------------------- --
// Title         : DCF77-Decoder
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : timeAndDateClock.v
// Author        : Tim Stadtmann
// Company       : IDS RWTH Aachen 
// Created       : 2018/09/20
// ------------------------------------------------------------------------- --
// Description   : Decodes the dcf77 signal
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/09/20  1.0      TS      Created
// ------------------------------------------------------------------------- --

module dcf77_decoder(clk,             // Global 10MHz clock 
                     clk_en_1hz,      // Indicates start of second
                     nReset,          // Global reset
                     minute_start_in, // New minute trigger
                     dcf_Signal_in,   // DFC Signal
                     timeAndDate_out,
                     data_valid,      // Control signal, High if data is valid
                     dcf_value);      // Decoded value of dcf input signal
                     
input clk, 
      clk_en_1hz,     
      nReset,  
      minute_start_in,
      dcf_Signal_in;  
      
output reg[43:0]  timeAndDate_out;
output reg	      data_valid;
output            dcf_value;
   
// ---------- YOUR CODE HERE ---------- 
// Internal signal definitions
reg [5:0] bit_count;           // Bit counter (0-58 for each DCF bit)
reg [58:0] received_bits;      // Register to hold received DCF77 bits for one minute
reg minute_parity_ok, hour_parity_ok, date_parity_ok;  // Parity checks

always @(posedge clk or negedge nReset) begin
    if (!nReset) begin
        // Reset all outputs and counters
        bit_count <= 0;
        received_bits <= 0;
        data_valid <= 0;
        timeAndDate_out <= 0;
    end else if (minute_start_in) begin
		// Start of new minute, reset counters and received_bits
		bit_count <= 0;
		received_bits <= 0;
		data_valid <= 0;
	end else if (clk_en_1hz) begin
		if (bit_count < 59) begin
            // Shift in the new bit and increment bit count
            received_bits[bit_count] <= !dcf_Signal_in;
            bit_count <= bit_count + 1;
            
            if (bit_count == 58) begin
				
				// Time Zone
				timeAndDate_out[43:42] <= received_bits[18:17];
				
				// Minutes (bits 21-27) - BCD to binary
				timeAndDate_out[13:7] <= received_bits[27:21];

				// Hours (bits 29-34) - BCD to binary
				timeAndDate_out[19:14] <= received_bits[34:29];

				// Day of Month (bits 36-41) - BCD to binary
				timeAndDate_out[25:20] <= received_bits[41:36];
				// Day of Week (bits 42-44) - Binary
				timeAndDate_out[41:39] <= received_bits[44:42];

				// Month (bits 45-49) - BCD to binary
				timeAndDate_out[30:26] <= received_bits[49:45];

				// Year (bits 50-57) - BCD to binary (only last two digits)
				timeAndDate_out[38:31] <= received_bits[57:50];
            end
        end 
    end	else begin
		// // ----------------- Parity checks ----------------- // //
		minute_parity_ok <= (bit_count == 59) ? (^received_bits[27:21] == received_bits[28]) : minute_parity_ok;
		hour_parity_ok <= (bit_count == 59) ? (^received_bits[34:29] == received_bits[35]) : hour_parity_ok;
		date_parity_ok <= (bit_count == 59) ? (^received_bits[57:36] == received_bits[58]) : date_parity_ok;
		// Final data validation
		data_valid <= minute_parity_ok && hour_parity_ok && date_parity_ok;
	end
end

assign dcf_value = !dcf_Signal_in; // Output the current value of DCF signal

endmodule              
              

