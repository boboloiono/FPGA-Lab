module clkGen_verilog(clk10,reset,resetValue_in,clk_enable);

input reset, clk10;
input[25:0] resetValue_in;
output clk_enable;
reg clk_enable;

reg counter;
reg enable;

parameter freq_divider=10000000;

always@(posedge clk10) 
begin
     if(reset==0)
           begin
             counter<=0;
             clk_enable<=0;
           end
     else if (counter == freq_divider - 1)
             begin 
               counter <= 0;
               clk_enable  <= 1;
             end
          else
             begin
             counter <= counter + 1;
             clk_enable  <= 0;     
             end 
 end    
endmodule