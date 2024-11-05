-- ------------------------------------------------------------------------- --
-- Title         : Driver for ALTERA LCD
-- Project       : Praktikum FPGA-Entwurfstechniken
-- ------------------------------------------------------------------------- --
-- File          : lcddriver.vhd
-- Author        : Alexander Flocke
-- Company       : EECS RWTH Aachen 
-- Created       : 2004/04/16
-- Last modified : 2004/10/19
-- ------------------------------------------------------------------------- --
-- Description   : This Entity Displays the Values, visible at Data_in on the
--                 LCD-Display at the Address specified by Addres_col_in
--                 (Column) and Address_row_in (Row).
--                 The Entity can Drive Displays up to a size of 64 Columns and
--                 2 Rows.
-- ------------------------------------------------------------------------- --
-- Copyright by EECS 2004 
-- ------------------------------------------------------------------------- --
-- Revisions     :
-- Date        Version  Author  Description
-- 2004/04/16  1.0      flocke  Created
-- 2004/06/29  1.1      fl/mn   blink update
-- 2004/10/18  1.2      mn      Blink und scoll update
-- ------------------------------------------------------------------------- --
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- ------------------------------------------------------------------------- --
-- Entity                                                                    --
-- ------------------------------------------------------------------------- --
entity lcddriver is
  generic (
    clk_freqeuncy : integer := 10000000);
                                          -- Clock-Freqency applied to clk in HZ
  port (
    Clk              : in    std_logic;   -- Clock
    nReset           : in    std_logic;   -- asynchronous Reset (active low)
    -- Data to be displayed on the LCD-Display --
    Data_in          : in    std_logic_vector(7 downto 0);
                                          -- data input
                                          -- (dddddddd) for ASCII
                                          -- (****dddd) for HEX
                                          -- (****dddd) for INTEGER
                                          -- where  * is don't care
                                          --        d is data bit
    Data_Mode_in     : in    std_logic_vector(1 downto 0);
                                          -- 00 : Data_in in ASCI-Format
                                          -- 01 : Data_in in Hex-Format
                                          -- 10 : Data_in in Dec-Format
    Data_valid_in    : in    std_logic;
    Addres_col_in    : in    std_logic_vector(5 downto 0);
    Address_row_in   : in    std_logic;   -- '0' Row 0, '1' row 1
    -- Control-Signals --
    Display_On_in    : in    std_logic;
    Display_Shift_in : in    std_logic_vector(1 downto 0);
                                          -- "00" No Scroll
                                          -- "10" Scroll left
                                          -- "01" scroll right
    Cursor_On_in     : in    std_logic;
    Cursor_Blink_in  : in    std_logic;   -- '1' Cursor blink On
    nReady_out       : out   std_logic;   -- If Signal is '1', no data can be
                                          -- displayed at the moment.
                                          -- Data_Valid_in is ignored unitl
                                          -- Signal is '0' again.
    -- Signals to LCD-Display --
    LCD_Data_io      : inout std_logic_vector(7 downto 0);
                                          -- data link to LCD board
    LCD_Enable_out   : out   std_logic;   -- Read/write enable signal (LCD)
	LCD_Contrast_out : out   std_logic;   -- Contrast signal 		  (LCD)
    LCD_RW_out       : out   std_logic;   -- Read/write selection     (LCD)
                                          -- H->Read, L->Write
    LCD_RS_out       : out   std_logic);  -- Register select          (LCD)
                                          -- H->Data, L->Instruction
end lcddriver;

-- ------------------------------------------------------------------------- --
-- Architecture                                                              --
-- ------------------------------------------------------------------------- --
architecture communicate of lcddriver is
  constant LCD_frequency : integer := 2000;
                                        -- Frequency, at wich the LCD-Display
                                        -- can receive Data. Cycle time must be
                                        -- greater than 20us to ensure the LCD
                                        -- control works properly.

  component FIFO
    port (data  : in  std_logic_vector(15 downto 0);   -- Input for FIFO Ram
          wrreq : in  std_logic;                       -- write Request
          rdreq : in  std_logic;                       -- read request
          clock : in  std_logic;                       -- clk
          aclr  : in  std_logic;                       -- asynchronous clear
          q     : out std_logic_vector(15 downto 0);   -- FIFO RAM output
          full  : out std_logic;                       -- FIFO is full
          empty : out std_logic;                       -- FIFO is empty
          usedw : out std_logic_vector (4 downto 0));  -- Number of words
                                                       -- currently used 
  end component;

  type states is (init,                 -- start initialization sequence
						init1a, init1b, 
						init2a, init2b, 
						init3a, init3b, 
						init4a, init4b, 
						init5a, init5b, 
						init6a, init6b, 
						init7a, init7b, 
                  hold,                 -- STOP state (clear display)
                  set0, set1,           -- determine display type
                  onoff0, onoff1,       -- cursor options
                  clear0, clear1,       -- clear display
                  mode0, mode1,         -- display mode
                  blink0, blink1,       -- blink mode on
                  blinkOff0, blinkOff1, -- blink mode off
                  shift0, shift1,       -- shift cursor to the left
                  wrad0, wrad1,         -- write address
                  wrcr0, wrcr1,         -- write character
                  rd_bf0, rd_bf1);      -- read busy flag
  -- Signals for the Statemaschine
  signal lcd_states                                : states := init;
  -- Signals to store Operating Modes of the LCD-Display
  signal Display_Shift_R                           : std_logic_vector(1 downto 0);
  signal Display_On_R, cursor_On_R, Cursor_blink_R : std_logic;
  -- Signals to generate Clk-Frequency
  signal clk_enable                                : std_logic := '0';
                                        -- Enable-Signale to send the Data to
                                        -- theLCD-Display at the correct speed 
  signal clk_count                                 : integer := 0;
                                        -- count_value to generate the
                                        -- clk_enable signal
  -- Signals from and to the FiFo
  signal data_all                                  : std_logic_vector(15 downto 0);
  signal fifo_data, fifo_address                   : std_logic_vector(7 downto 0);
  signal read_req                                  : std_logic;
  signal async_clear                               : std_logic;
  signal fifo_empty                                : std_logic;
  -- Signals for LCD-Control
  signal write_enable_lcd                          : std_logic;
  signal lcd_enable                                : std_logic;
  signal wait_counter                              : integer range 0 to 100  := 0;
begin  -- communicate
-- ----- GENERATE CLOCK ENABLE SIGNAL ---------------------------------------
  -- Cycle time must be greater than 20us to ensure the LCD control works
  -- properly. Selecet constant LCD_frequency accordingly.    
  process (clk, nReset)
  begin  -- process
    if nReset = '0' then                -- asynchronous reset (active low)
      clk_enable <= '0';
      clk_count  <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if clk_count = clk_freqeuncy / LCD_frequency then
        clk_enable <= '1';
        clk_count  <= 0;
      else
        clk_count  <= clk_count +1;
        clk_enable <= '0';
      end if;
    end if;
  end process;

-- ----- DATA INPUT MAPPING -------------------------------------------------
  process (Addres_col_in, Address_row_in, Data_Mode_in, Data_in)
  begin  -- process
    -- The input data is mapped to the equivalent entry of the code table of
    -- the LCD driver character ROM. See "http://www.samsung.com/Products/
    -- Semiconductor/SystemLSI/DDI/MobileDDI/BWSTN/S6A0069X/s6a0069-04.pdf" for
    -- details.
    case Data_Mode_in is
      when "00" =>                      -- ASCII type
        fifo_data <= Data_in;
      when "01" =>                      -- HEX type
        case Data_in(3 downto 0) is
          when x"0"|x"1"|X"2"|x"3"|x"4"|X"5"|x"6"|x"7"|X"8"|x"9" =>
            fifo_data <= x"3"&Data_in(3 downto 0);
          when x"A" =>
            fifo_data <= x"41";
          when x"B" =>
            fifo_data <= x"42";
          when x"C" =>
            fifo_data <= x"43";
          when x"D" =>
            fifo_data <= x"44";
          when x"E" =>
            fifo_data <= x"45";
          when x"F" =>
            fifo_data <= x"46";
          when others =>
            fifo_data <= x"58";         -- 'X'
        end case;
      when "10" =>                      -- INTEGER type
        case Data_in(3 downto 0) is
          when x"0"|x"1"|X"2"|x"3"|x"4"|X"5"|x"6"|x"7"|X"8"|x"9" =>
            fifo_data <= x"3"&Data_in(3 downto 0);
          when others =>
            fifo_data <= x"58";         -- 'X'
        end case;
      when others =>                    -- Type error => output: blank
        fifo_data <= (others => '0');
    end case;
    -- Address Mapping --
    -- The LCD address command starts with a '1' in the MSB. The address
    -- is coded as follows: the leading HEX character is coded in three
    -- bits, the following HEX character is coded with four bits.
    --
    -- LCD Matrix with 2x16 entries:
    --    1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
    -- ,----------------------------------------------------------------.
    -- | 00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D  0E  0F |
    -- |----------------------------------------------------------------|
    -- | 40  41  41  43  44  45  46  47  48  49  4A  4B  4C  4D  4E  4F |
    -- `----------------------------------------------------------------'
    fifo_Address <= ('1' & Address_row_in & Addres_col_in);
  end process;

-- ----- FIFO Instanciaion ----------------------------------------------------
  -- The FiFo is needed to store Data temporaly, which is send into the Entity
  -- at a  higher clk-frequency, than the operating-frequency of the
  -- LCD-Display 
  async_clear      <= not(nRESET);
  write_enable_lcd <= not(fifo_empty);
  MAP_FIFO : FIFO
    port map (data  => fifo_address & fifo_data,  -- input data
              wrreq => Data_Valid_in,   -- write request (input data is valid) 
              rdreq => read_req,        -- read request
              clock => clk,             -- clock
              aclr  => async_clear,     -- asynchronous clear (active high)
              q     => data_all,        -- FIFO output
              full  => nReady_out,      -- FIFO full flag (when usedw >= 30)
              empty => fifo_empty);     -- FIFO empty flag

-- ----- LCD STATE MACHINE --------------------------------------------------
  process (clk, nRESET)
  begin  -- process
    if nRESET = '0' then                -- asynchronous reset (active low)
      lcd_states <= hold;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if clk_enable = '1' then
        case lcd_states is
		    when init   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init1a;
				  wait_counter <= 0;
				end if;
		    when init1a   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init1a;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init1b;
				  wait_counter <= 0;
				end if;
		    when init1b   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init1b;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init2a;
				  wait_counter <= 0;
				end if;
		    when init2a   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init2a;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init2b;
				  wait_counter <= 0;
				end if;
		    when init2b   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init2b;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init3a;
				  wait_counter <= 0;
				end if;
		    when init3a   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init3a;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init3b;
				  wait_counter <= 0;
				end if;
		    when init3b   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init3b;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init4a;
				  wait_counter <= 0;
				end if;
		    when init4a   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init4a;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init4b;
				  wait_counter <= 0;
				end if;
		    when init4b   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init4b;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init5a;
				  wait_counter <= 0;
				end if;
		    when init5a   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init5a;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init5b;
				  wait_counter <= 0;
				end if;
		    when init5b   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init5b;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init6a;
				  wait_counter <= 0;
				end if;
		    when init6a   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init6a;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init6b;
				  wait_counter <= 0;
				end if;
		    when init6b   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init6b;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init7a;
				  wait_counter <= 0;
				end if;
		    when init7a   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init7a;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= init7b;
				  wait_counter <= 0;
				end if;
		    when init7b   => 
			   if (wait_counter < 80) then 
				  lcd_states <= init7b;
				  wait_counter <= wait_counter + 1;
				else
				  lcd_states <= hold;
				  wait_counter <= 0;
				end if;
				
          when hold   => lcd_states <= set0;
      
          when set0   => lcd_states <= set1;
          when set1   => lcd_states <= onoff0;

          when onoff0 => lcd_states <= onoff1;
          when onoff1 => lcd_states <= clear0;
          
          when clear0 => lcd_states <= clear1;
          when clear1 => lcd_states <= blink0;  --shift0;
          
          when shift0 => lcd_states <= shift1;
          when shift1 => lcd_states <= blink0;
          
          when blink0 => lcd_states <= blink1;
          when blink1 => lcd_states <= mode0;
          
          when mode0  => lcd_states <= mode1;
          when mode1  =>
            if write_enable_lcd = '1' then
                                        -- if new data is
                                        -- availabel, display character on
                                        -- LCD-Display else wait for new
                                        -- data
              lcd_states <= blinkOff0;
            elsif (Display_On_in /= Display_On_R or
                   Cursor_blink_in /= Cursor_blink_R or
                   cursor_On_in /= cursor_On_R) then
              lcd_states <= blink0;
            elsif (Display_Shift_R /= Display_Shift_in) then
              lcd_states <= shift0;
            else
              lcd_states <= mode1;
            end if;

          when blinkOff0 => lcd_states <= blinkOff1;
          when blinkOff1 => lcd_states <= wrad0;

          when wrad0     => lcd_states <= wrad1;
          when wrad1     => lcd_states <= wrcr0;
          
          when wrcr0     => lcd_states <= wrcr1;
          when wrcr1     => lcd_states <= rd_bf0;
          
          when rd_bf0    =>
            if LCD_Data_io(7) = '1' then
              lcd_states <= rd_bf1;
            else
              lcd_states <= shift0;
            end if;
          when rd_bf1 =>
            if LCD_Data_io(7) = '1' then
              lcd_states <= rd_bf0;
            else
              lcd_states <= shift0;
            end if;
            -- DATA_LCD(7) is used as a "busy-flag"
            -- that indicates an internal
            -- operation. While bf is high, no data
            -- can be written to the display.
          when others => lcd_states <= hold;
        end case;
      end if;
    end if;
  end process;
  
  -- Register --
  process (clk, nReset)
  begin  -- process
    if nReset = '0' then                -- asynchronous reset (active low)
      Display_Shift_R <= "00";
      cursor_On_R     <= '0';
      Cursor_blink_R  <= '0';
      Display_On_R    <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if clk_enable = '1' then
        Display_Shift_R <= Display_Shift_R;
        Display_On_R    <= Display_On_R;
        Cursor_blink_R  <= Cursor_blink_R;
        cursor_On_R     <= cursor_On_R;
        case lcd_states is
          when shift1 =>
            Display_Shift_R <= Display_Shift_in;
          when blink1 =>
            Cursor_blink_R <= Cursor_blink_in;
            cursor_On_R    <= cursor_On_in;
            Display_On_R   <= Display_On_in;
          when others => null;
        end case;
      end if;
    end if;
  end process;

-- ----- CONTROL SIGNALS ----------------------------------------------------
  -- Certain control signals are driven by this process:

  -- Enable, register select (RS) and read/write (RW) are set depending on
  -- the recent state.
  -- register select (RS) defines where the data is going to (comming from)
  -- RS = '1' means DATA register, RS = '0' refers to the instruction
  -- register.
  -- read/write (RW) toggles the data flow direction. RW = '1' denotes that
  -- the data is read from the LCD, RW = '0' means, data is written to the
  -- LCD.
  -- Enable turns the read-/ write-operation on and off ('1' and '0');

  -- lcd_enable is set to '0' when the state machine is in "read busy-flag"
  -- mode. In this case, the output DATA_LCD is set to 'Z' (tristate) so the
  -- LCD driver chip control the DATA_LCD pins.

  -- Whenever the state machine turns into state "mode", a new value is read
  -- from the FIFO, when the write_enable_lcd is '1' (FIFO is not empty).

  process (clk_enable, lcd_states, write_enable_lcd)
    variable lcd_control : std_logic_vector(0 to 2);
  begin  -- process

    --                                                               E RS RW
    case lcd_states is
	   when init1a | init2a | init3a | init4a | init5a | init6a | init7a 
		     => lcd_control := "000";
	   when init1b | init2b | init3b | init4b | init5b | init6b | init7b 
		     => lcd_control := "100";
		when hold => lcd_control := "000";
      when set0|onoff0|clear0|mode0|wrad0|blink0|
        shift0|blinkOff0 => lcd_control := "100";
      when set1|onoff1|clear1|mode1|wrad1|blink1|
        shift1|blinkOff1 => lcd_control := "000";
      when wrcr0  => lcd_control := "110";
      when wrcr1  => lcd_control := "010";
      when rd_bf0 => lcd_control := "001";
      when rd_bf1 => lcd_control := "101";
      when others => lcd_control := "000";
    end case;

    LCD_Enable_out <= lcd_control(0);
    LCD_RS_out     <= lcd_control(1);
    LCD_RW_out     <= lcd_control(2);
	LCD_Contrast_out<= '0';
	 
    if lcd_states = rd_bf0 or lcd_states = rd_bf1 then
      lcd_enable <= '0';
    else
      lcd_enable <= '1';
    end if;

    if lcd_states = mode0 and write_enable_lcd = '1' and clk_enable = '1' then
      read_req <= '1';
    else
      read_req <= '0';
    end if;
  end process;

-- ----- OUTPUT DATA MAPPING ------------------------------------------------
  process (Cursor_blink_in, Display_On_in, Display_Shift_in, cursor_On_in,
           data_all, lcd_enable, lcd_states)
    variable local_data : std_logic_vector(7 downto 0);
  begin  -- process
    case lcd_states is
	   when init1a | init1b | init2a | init2b | init3a | init3b 
		     => local_data := "00110000";
	   when init4a | init4b
		     => local_data := "00111000";
	   when init5a | init5b
		     => local_data := "00001000";
	   when init6a | init6b
		     => local_data := "00000001";
	   when init7a | init7b
		     => local_data := "00000110";
      when hold =>
        local_data := "00000001";       -- clear display 
      when set0|set1 =>
        local_data := "00111111";  -- set display in 2-row mode, display on
      when onoff0|onoff1 =>
        local_data := "00001"&Display_On_in&cursor_On_in&Cursor_blink_in; 
      when clear0|clear1 =>
        local_data := "00000001";       -- clear display
      when mode0|mode1 =>
        case Display_Shift_in is
          when "01" =>                  -- Display-Shift Right
            local_data := "00000111";
          when "10" =>                  -- Display-Shift Left
            local_data := "00000101";
          when others =>                -- No Display-Shift
            local_data := "00000110";
        end case;
      when shift0|shift1 =>
        local_data := "00010000";       -- shift cursor to the left   
      when blink0|blink1 =>
        local_data := "00001"&Display_On_in&cursor_On_in&Cursor_blink_in;
      when blinkOff0|blinkOff1 =>
        local_data := "00001"&Display_On_in&"00";
      when wrad0|wrad1 =>
        local_data := data_all(15 downto 8);  -- write address to LCD
      when others =>
        local_data := data_all(7 downto 0);   -- write character to LCD
    end case;

    if lcd_enable = '1' then
      LCD_Data_io <= local_data;
    else
      LCD_Data_io <= (others => 'Z');
      -- output is set "tristate" so the
      -- LCD drives the pins and data can be
      -- read from the LCD.
    end if;
    
  end process;
end communicate;
