// ------------------------------------------------------------------------- --
// Title         : SetClock
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : setClock.v
// Author        : Tim Stadtmann
// Company       : IDS RWTH Aachen 
// Created       : 2018/09/27
// ------------------------------------------------------------------------- --
// Description   : Implements functionality for setting the clock
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/09/27  1.0      TS      Created
// ------------------------------------------------------------------------- --

module setClock(clk, nReset, enter_in, set_in, stateControl_in, timeAndDate_In, timeAndDate_Out, stateSetClock_out);

input           clk;
input           nReset;
input           enter_in;
input           set_in;
input     [5:0] stateControl_in;
input    [43:0] timeAndDate_In;
output   [43:0] timeAndDate_Out;
output    [3:0] stateSetClock_out;

// state machine states
localparam idle = 5'b00000;
localparam setSecondLow = 5'b00001;
localparam setSecondHigh = 5'b00010;
localparam setMinuteLow = 5'b00011;
localparam setMinuteHigh = 5'b00100;
localparam setHourLow = 5'b00101;
localparam setHourHigh = 5'b00110;
localparam setDayLow = 5'b00111;
localparam setDayHigh = 5'b01000;
localparam setMonthLow = 5'b01001;
localparam setMonthHigh = 5'b01010;
localparam setYearLow = 5'b01011;
localparam setYearHigh =5'b01100;
localparam setWeekday = 5'b01101;
localparam getActTime = 5'b01110;
localparam finished1 = 5'b01111;
localparam finished2 = 5'b10000;
// button states
localparam none = 3'b000;
localparam set_press = 3'b001;
localparam set_up = 3'b010;
localparam enter_press = 3'b011;
localparam enter_up = 3'b100;

reg      [43:0] timeAndDate_Out;
reg       [3:0] stateSetClock_out;

reg unsigned[3:0] secondLowDigit;
reg unsigned[2:0] secondHighDigit;
reg unsigned[3:0] minuteLowDigit;
reg unsigned[2:0] minuteHighDigit;
reg unsigned[3:0] hourLowDigit;
reg unsigned[1:0] hourHighDigit;
reg unsigned[3:0] dayLowDigit;
reg unsigned[1:0] dayHighDigit;
reg unsigned[3:0] monthLowDigit;
reg unsigned      monthHighDigit;
reg unsigned[3:0] yearLowDigit;
reg unsigned[3:0] yearHighDigit;
reg unsigned[2:0] weekdayDigit;

reg [4:0] state;
reg [2:0] btn_ctrl_state;

reg clkEnableInt;
reg setInt, enterInt, resetInt;
reg setPrev, enterPrev;

integer clkCount;

parameter clk_frequency = 10000000;
localparam internal_clock_frequency = 4000;
 
// Map new time to output ports
always@(secondLowDigit,secondHighDigit,minuteLowDigit,minuteHighDigit,hourLowDigit,hourHighDigit,dayLowDigit,
         dayHighDigit,monthLowDigit,monthHighDigit,yearLowDigit,yearHighDigit,weekdayDigit)
begin
  timeAndDate_Out[3:0]   <= 4'b0000;
  timeAndDate_Out[6:4]   <= 3'b000;
  timeAndDate_Out[10:7]  <= minuteLowDigit;
  timeAndDate_Out[13:11] <= minuteHighDigit;
  timeAndDate_Out[17:14] <= hourLowDigit;
  timeAndDate_Out[19:18] <= hourHighDigit;
  timeAndDate_Out[23:20] <= dayLowDigit;
  timeAndDate_Out[25:24] <= dayHighDigit;
  timeAndDate_Out[29:26] <= monthLowDigit;
  timeAndDate_Out[30]    <= monthHighDigit;
  timeAndDate_Out[34:31] <= yearLowDigit;
  timeAndDate_Out[38:35] <= yearHighDigit;
  timeAndDate_Out[41:39] <= weekdayDigit;
  timeAndDate_Out[43:42] <= 2'b00;
end

// Generate internal clock enable
always@(posedge clk or negedge nReset)
begin
  if(nReset==0) begin
    clkCount <= 0;
    clkEnableInt <= 0;
  end
  else if(clk==1) begin
    if(clkCount < clk_frequency / internal_clock_frequency) begin
      clkCount <= clkCount + 1;
      clkEnableInt <= 0;
    end 
    else begin
      clkCount <= 0;
      clkEnableInt <= 1;
    end
  end
end


// Generate internal set- and enter-signal
always@(posedge clk or negedge nReset)
begin
  if(nReset==0) begin
    setInt <= 0;
    enterInt <= 0;
  end
  else if(clkEnableInt==1) begin
    if(enterPrev==1 && enter_in==0)
      enterInt <= 1;
    else
      enterInt <= 0;
      
    if(setPrev==1 && set_in==0)
      setInt <= 1;
    else
      setInt <= 0;
    
    setPrev <= set_in;
    enterPrev <= enter_in;
  end
end

// Generate internal reset signal
always@(stateControl_in)
begin
  if(nReset==0 || stateControl_in[5:4]!=2'b10)
    resetInt <= 0;
  else
    resetInt <= 1;
end

// ---- State Machine ----
// State change logic
always@(posedge clk or negedge resetInt)
begin
  if(resetInt==0) begin 
    state <= idle;
  end
  else if(clkEnableInt==1) begin
    // state <= state;
    case(state)
      idle:
      begin
        if(stateControl_in[5:4] == 2'b10)
          state <= getActTime;
      end
      
      getActTime:
      begin
        state <= setHourHigh;
      end
      
      setHourHigh:
      begin
        if(setInt==1)
          state <= setHourLow;
        
      end
      
      setHourLow:
      begin
        if(setInt==1)
          state <= setMinuteHigh;
        
      end

      setMinuteHigh:
      begin
        if(setInt==1)
          state <= setMinuteLow;
        
      end
      
      setMinuteLow:
      begin
        if(setInt==1)
          state <= setDayHigh;
        
      end
      
      setDayHigh:
      begin
        if(setInt==1)
          state <= setDayLow;
        
      end
      
      setDayLow:
      begin
        if(setInt==1)
          state <= setMonthHigh;
        
      end
      
      setMonthHigh:
      begin
        if(setInt==1)
          state <= setMonthLow;
        
      end
      
      setMonthLow:
      begin
        if(setInt==1)
          state <= setYearHigh;
        
      end
      
      setYearHigh:
      begin
        if(setInt==1)
          state <= setYearLow;
        
      end
      
      setYearLow:
      begin
        if(setInt==1)
          state <= setWeekday;
        
      end
      
      setWeekday:
      begin
        if(setInt==1)
          state <= finished1;
        
      end
      
      finished1:
      begin
        state <= finished2;
      end
      
      finished2:
      begin
        if(stateControl_in[5:4] == 2'b10)
          state <= state;
        else
          state <= idle;
      end
      
      default:
      begin
        state <= state;
      end
    endcase
  end
end

// Storage and output logic
always@(posedge clk or negedge nReset)
begin
  if(nReset==0) begin
    stateSetClock_out <= 4'b0000;
    secondLowDigit <= 4'b0000;
    secondHighDigit <= 3'b000;
    minuteLowDigit <= 4'b0000;
    minuteHighDigit <= 3'b000;
    hourLowDigit <= 4'b0000;
    hourHighDigit <= 2'b00;
    dayLowDigit <= 4'b0000;
    dayHighDigit <= 2'b00;
    monthLowDigit <= 4'b0000;
    monthHighDigit <= 1'b0;
    yearLowDigit <= 4'b0000;
    yearHighDigit <= 4'b0000;
    weekdayDigit <= 3'b000;
  end
  else if(clk==1) begin
    if(clkEnableInt==1) begin
      stateSetClock_out <= 4'b0000;
      
      case(state)
        idle: 
          ;
      
        getActTime:
        begin
          secondLowDigit <= timeAndDate_In[3:0];
          secondHighDigit <= timeAndDate_In[6:4];
          minuteLowDigit <= timeAndDate_In[10:7];
          minuteHighDigit <= timeAndDate_In[13:11];
          hourLowDigit <= timeAndDate_In[17:14];
          hourHighDigit <= timeAndDate_In[19:18];
          dayLowDigit <= timeAndDate_In[23:20];
          dayHighDigit <= timeAndDate_In[25:24];
          monthLowDigit <= timeAndDate_In[29:26];
          monthHighDigit <= timeAndDate_In[30];
          yearLowDigit <= timeAndDate_In[34:31];
          yearHighDigit <= timeAndDate_In[38:35];
          weekdayDigit <= timeAndDate_In[41:39];
          stateSetClock_out <= 4'hC;
        end
        
        setHourHigh:
        begin
          stateSetClock_out <= 4'h1;
          if(enterInt==1) begin
            if(hourHighDigit==2'b00) 
              hourHighDigit <= 2'b01;
            else if(hourHighDigit==2'b01) begin
              hourHighDigit <= 2'b10;
              if(hourLowDigit>3) 
                hourLowDigit = 4'h0;
            end
            else
              hourHighDigit <= 2'b00;
          end
        end
        
        setHourLow:
        begin
          stateSetClock_out <= 4'h2;
          if(enterInt==1) begin
            if((hourHighDigit!=2 && hourLowDigit<9) || (hourHighDigit==2 && hourLowDigit<3))
              hourLowDigit <= hourLowDigit + 4'h1;
            else
              hourLowDigit <= 4'h0;
          end
        end
  
        setMinuteHigh:
        begin
          stateSetClock_out <= 4'h3;
          if(enterInt==1) begin
            if(minuteHighDigit<5)
              minuteHighDigit <= minuteHighDigit + 3'b001;
            else
              minuteHighDigit <= 3'b000;
          end
        end
        
        setMinuteLow:
        begin
          stateSetClock_out <= 4'h4;
          if(enterInt==1) begin
            if(minuteLowDigit<9)
              minuteLowDigit <= minuteLowDigit + 4'h1;
            else
              minuteLowDigit <= 4'h0;
          end
        end
        
        setDayHigh:
        begin
          stateSetClock_out <= 4'h5;
          if(enterInt==1) begin
            if(dayHighDigit!=3)
              dayHighDigit <= dayHighDigit + 2'b01;
            else begin
              if(dayLowDigit>1)
                dayLowDigit <= 4'h0;
                
              dayHighDigit <= 2'b00;
            end
          end
        end
        
        setDayLow:
        begin
          stateSetClock_out <= 4'h6;
          if(enterInt==1) begin
            if((dayHighDigit!=3 && dayLowDigit<9) || (dayHighDigit==3 && dayLowDigit<1))
              dayLowDigit <= dayLowDigit + 4'h1;
            else if(dayHighDigit==0)
              dayLowDigit <= 4'h1;
            else
              dayLowDigit <= 4'h0;
          end
        end
        
        setMonthHigh:
        begin
          stateSetClock_out <= 4'h7;
          if(enterInt==1) begin
            if(monthHighDigit==1 && monthLowDigit>2)
              monthLowDigit <= 4'h0;
              
            monthHighDigit <= ~monthHighDigit;
          end
        end
        
        setMonthLow:
        begin
          stateSetClock_out <= 4'h8;
          if(enterInt==1) begin
            if((monthLowDigit<9 && monthHighDigit==0) || (monthHighDigit==1 && monthLowDigit<2))
              monthLowDigit <= monthLowDigit + 4'h1;
            else if(monthHighDigit==0)
              monthLowDigit <= 4'h1;
            else
              monthLowDigit <= 4'h0;
          end
        end
        
        setYearHigh:
        begin
          stateSetClock_out <= 4'h9;
          if(enterInt==1) begin
            if(yearHighDigit<9)
              yearHighDigit <= yearHighDigit + 4'h1;
            else
              yearHighDigit <= 4'h0;
            
          end
        end
        
        setYearLow:
        begin
          stateSetClock_out <= 4'hA;
          if(enterInt==1) begin
            if(yearLowDigit<9)
              yearLowDigit <= yearLowDigit + 4'h1;
            else
              yearLowDigit <= 4'h0;
          end
        end
        
        setWeekday:
        begin
          stateSetClock_out <= 4'hB;
          if(enterInt==1) begin
            if(weekdayDigit<7)
              weekdayDigit <= weekdayDigit + 3'b001;
            else
              weekdayDigit <= 3'b001;
          end
        end
        
        finished1:
        begin
          stateSetClock_out <= 4'hD;
        end
        
        finished2:
        begin
          stateSetClock_out <= 4'hE;
        end
        
        default:
        begin
          stateSetClock_out <= 4'hF;
        end
      endcase
    end
  end
end

endmodule