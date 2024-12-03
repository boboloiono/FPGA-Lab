module control_unit(clk, clk_en, nReset, DCF_Enable_in, SET_in, STATE_out, DCF_timeAndDate_in,
                     DCF_set_in, SetClock_timeAndDate_in, SetClock_state_in, clock_timeAndDate_In,
                     LCD_timeAndDate_Out, clock_timeAndDate_Out, clock_set_out);

   input          clk;
   input          clk_en;
   input          nReset;
   input          DCF_Enable_in;
   input          SET_in;
   //input [1:0]	  Set_select,        // Assuming Set_select is 2 bits as per diagram

   output  [5:0]  STATE_out;
   // -------DATA FROM DCF DECODER
   input  [43:0]  DCF_timeAndDate_in;
   input          DCF_set_in;
   // -------DATA FROM SET CLOCK
   input  [43:0]  SetClock_timeAndDate_in;
   input   [3:0]  SetClock_state_in;
   // -------DATA FROM CLOCK
   input  [43:0]  clock_timeAndDate_In;
   // -------DATA OUTPUT LCD-Matrix-Display
   output [43:0]  LCD_timeAndDate_Out;
   // -------DATA TO CLOCK
   output [43:0]  clock_timeAndDate_Out;
   output         clock_set_out;

   reg        clock_set_out_reg;
   reg [5:0]  STATE_out_reg;
   reg [43:0] LCD_timeAndDate_Out_reg;
   reg [43:0] clock_timeAndDate_Out_reg;
   
   assign clock_set_out = clock_set_out_reg;
   assign STATE_out = STATE_out_reg;
   assign LCD_timeAndDate_Out = LCD_timeAndDate_Out_reg;
   assign clock_timeAndDate_Out = clock_timeAndDate_Out_reg;
      
   // ---------- YOUR CODE HERE ---------- 
	// State encoding
    typedef enum logic [3:0] {
		SELECT_CLOCK = 4'b0000,
		SELECT_DCF77 = 4'b0001,
		SET_CLOCK = 4'b0010
	} state_t;
	
	state_t current_state, next_state;
	
	// State Transition Logic
    always @(posedge clk_en or negedge nReset) begin
        if (!nReset) begin
            current_state <= state_t'(SetClock_state_in);  // Initial state
        end else begin
            current_state <= next_state;
        end
    end
	
	
	
	
	always @(*) begin
		case (current_state)
			SELECT_CLOCK: begin
				STATE_out_reg <= 6'b0;
				LCD_timeAndDate_Out_reg <= clock_timeAndDate_In;
				clock_timeAndDate_Out_reg <= SetClock_timeAndDate_in;
				clock_set_out_reg <= 1'b0;
			end
			
			SELECT_DCF77: begin
				STATE_out_reg <= 6'b110000;
				LCD_timeAndDate_Out_reg <= clock_timeAndDate_In;
				clock_timeAndDate_Out_reg <= DCF_timeAndDate_in;
				clock_set_out_reg <= DCF_set_in;
			end
			
			SET_CLOCK: begin
				STATE_out_reg <= {2'b10, SetClock_state_in};
				LCD_timeAndDate_Out_reg <= SetClock_timeAndDate_in;
				clock_timeAndDate_Out_reg <= SetClock_timeAndDate_in;
				clock_set_out_reg <= (SetClock_state_in == 4'd13 || SetClock_state_in == 4'd14) ? 1'b1 : 1'b0; 
			end
			
			default: begin
				STATE_out_reg <= 6'b0;
				LCD_timeAndDate_Out_reg <= 44'b0;
				clock_timeAndDate_Out_reg <= 44'b0;
				clock_set_out_reg <= 1'b0;
			end
		endcase
	end
	 
	 // Output logic
	 always @(*) begin
		case(current_state)
			SELECT_CLOCK: begin
				if(DCF_Enable_in) next_state = SELECT_DCF77;
				else if(!SET_in && !DCF_Enable_in) next_state = SET_CLOCK;
				else next_state = SELECT_CLOCK;
			end
			
			SELECT_DCF77: begin
				if(!DCF_Enable_in) next_state = SELECT_CLOCK;
				else next_state = SELECT_DCF77;
			end
			SET_CLOCK: begin
				if(DCF_Enable_in) next_state = SELECT_DCF77;
				else if(SetClock_state_in == 4'd14) next_state = SELECT_CLOCK;
				else next_state = SET_CLOCK;
			end
			default: next_state = SELECT_CLOCK;
		endcase
	 
	 end
endmodule