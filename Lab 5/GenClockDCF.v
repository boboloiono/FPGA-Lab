// ------------------------------------------------------------------------- --
// Title         : Clock generator (async and sync with DCF)
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : timeAndDateClock.v
// Author        : Shutao Zhang
// Company       : IDS RWTH Aachen 
// Created       : 2018/08/16
// ------------------------------------------------------------------------- --
// Description   : A clock generator for a DCF77 radio-controlled clock
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/08/16  1.0      SH      Created
// 2018/09/20  1.1      TS      Clean up, comments
// ------------------------------------------------------------------------- --

module GenClockDCF(clk,                   // 10 MHz clock
                   nReset,                // global reset (active low)
                   DCF_SELECT_in,         // DCF signal is selected
                   DCF_SIGNAL_in,         // DCF signal from antenna (1 Hz domain)
                   CLK_ENA_HZ_async_out,  // clock enable signal (1 Hz domain)
                   CLK_ENA_HZ_sync_out,   // clock enable synchronous to new minute flag
                   MINUTE_START_out);     // new minute flag
  input clk,          
        nReset,
        DCF_SELECT_in,
        DCF_SIGNAL_in;
  
  output CLK_ENA_HZ_async_out,
         CLK_ENA_HZ_sync_out,
         MINUTE_START_out;
  
  reg DCF_SIGNAL_out,
      CLK_ENA_HZ_async_out,
      CLK_ENA_HZ_sync_out,
      MINUTE_START_out;
         
  parameter frequency = 10000000;
  parameter fir_len   = 32;
  parameter thresh_lo = 14;
  parameter thresh_hi = 16;
  parameter timestep  = 128;
  parameter sample_point=frequency*3/20;  // 150 ms after falling edge
  
  integer async_counter,
          sync_counter;
          
  reg int_minute_start,
      last_DCF,
      detected_edge,
      DCF_intern;
      
  reg[fir_len-1:0] delay_line; // FIR window
  integer fir_out, // no of 1's in delay_line
          cycle_cnt;

always@(posedge clk, negedge nReset)
begin
  if(!nReset) begin
    delay_line     <= 0;
    fir_out        <= 0;
    cycle_cnt      <= 0;
    DCF_SIGNAL_out <= 0;
  end
  else begin 
    begin
      if(cycle_cnt==0) begin // Shift-in new value while keeping fir_out up to date
        cycle_cnt <= timestep - 1;
        
        begin
          if((delay_line[fir_len-1] == 1) && (fir_out > 0)) 
            fir_out <= fir_out - 1;
        end
        
        delay_line <= {delay_line[fir_len-2:0],DCF_SIGNAL_in }; // Left-shift delay-line, newest DCF value in LSB 
        
        begin
          if((delay_line[0] == 1) && (fir_out < fir_len)) 
            fir_out <= fir_out + 1;
        end
      end
      else  
        cycle_cnt <= cycle_cnt - 1;
    end
        
    last_DCF <= DCF_intern;
    if(fir_out >= thresh_hi) begin // Actual filtering: if more than tresh_hi 1's in current FIR window, set to 1
      DCF_intern     <= 1;
      DCF_SIGNAL_out <= 1;
    end
    else if (fir_out <= thresh_lo) begin// if less than thresh_lo 1's in current FIR window, set to 0
      DCF_intern     <= 0;
      DCF_SIGNAL_out <= 0;
    end             
  end
end

// ----- GENERATE ASYNCHRONOUS CLOCK ENABLE ---------------------------------
// The asynchronous signal is high for one clock cycle every second. This 
// signal is not linked to the DCF signal.
always@(posedge clk, negedge nReset)
begin
  if(!nReset) begin
    async_counter        <= 0;
    CLK_ENA_HZ_async_out <= 0;
  end
  else if(async_counter < frequency) begin
    async_counter        <= async_counter + 1;
    CLK_ENA_HZ_async_out <= 0;
  end
  else begin
    async_counter        <= 0;
    CLK_ENA_HZ_async_out <= 1;
  end
end

// ----- GENERATE SYNCHRONOUS CLOCK ENABLE ----------------------------------
// The synchronous signal is high for one clock cycle during the sample point
// 150 ms after a falling edge is detected in the DCF signal.
always@(posedge clk, negedge nReset)
begin
  if(!nReset)
    CLK_ENA_HZ_sync_out <= 0;
  else if(sync_counter == sample_point)
    CLK_ENA_HZ_sync_out <= 1;
  else 
    CLK_ENA_HZ_sync_out <= 0;
end

  // ----- FILTER INPUT SIGNAL ------------------------------------------------
  // The DCF77 signal may have spikes that last longer than a clock cycle. To
  // filter these spikes, a falling edge is accepted only if the signal change
  // lasts longer than a certain number of clock cycles
  // (defined by filter_max).
//  process (CLK, nRESET)
//  begin  -- process  
//    if nRESET = '0' then                -- asynchronous reset (active low)
//      last_DCF   <= '0';
//      filter_cnt <= 0;
//    elsif CLK'event and CLK = '1' then  -- rising clock edge
//      last_DCF <= DCF_SIGNAL_in;
//      if last_DCF = '1' and DCF_SIGNAL_in = '0' then
//        filter_cnt <= 0;
//      elsif last_DCF = '0' and DCF_SIGNAL_in = '0' then
//        if filter_cnt < filter_max then
//          filter_cnt <= filter_cnt + 1;
//        else
//          filter_cnt <= filter_max;
//        end if;
//      else
//        filter_cnt <= filter_max;
//      end if;
//    end if;
//  end process;

// ----- GENERATE NEW MINUTE FLAG SIGNAL ------------------------------------
always@(posedge clk, negedge nReset)
begin
  if(!nReset) begin
    sync_counter     <= 0;
    detected_edge    <= 0;
    int_minute_start <= 0;
  end
  else begin
     if(sync_counter < frequency) begin
       if((last_DCF == 1) && (DCF_intern == 0)) begin // falling edge
         sync_counter  <= ((fir_len - thresh_lo) * timestep / 2); 
         detected_edge <= 1;         
       end
       else begin
         sync_counter  <= sync_counter + 1;
         detected_edge <= detected_edge;
       end
     end
     else begin
      sync_counter  <= 0;
      detected_edge <= 0;
     end
    
    if(sync_counter == sample_point)
      int_minute_start <= (DCF_SELECT_in && !(detected_edge)); // If no edge detected - new minute trigger
    else
      int_minute_start <= (DCF_SELECT_in && int_minute_start);
  end
end
  
 always@(int_minute_start)
 begin
   MINUTE_START_out <= int_minute_start;
 end
  
endmodule