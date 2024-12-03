-- ------------------------------------------------------------------------- --
-- Title         : Darstellung der Zeit einer DCF-Funkuhr auf einem LCD-Display
-- Project       : Praktikum FPGA-Entwurfstechniken
-- ------------------------------------------------------------------------- --
-- File          : lcdSteuerung.vhd
-- Author        : Martin Neunenhahn
-- Company       : EECS RWTH Aachen 
-- Created       : 2004/04/16
-- Last modified : 2004/10/19
-- ------------------------------------------------------------------------- --
-- Description   : Diese Entity stellt die Uhrezeit einer DCF77-Funkuhr auf
--                 einem Zweizeiligen LCD-Display dar. 
-- ------------------------------------------------------------------------- --
-- Copyright by EECS 2004 
-- ------------------------------------------------------------------------- --
-- Revisions     :
-- Date        Version  Author  Description
-- 2004/04/16  1.0      MN      Created
-- 2004/10/19  1.1      MN      Adaption an neuen LCD-Driver  
-- ------------------------------------------------------------------------- --
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- ------------------------------------------------------------------------- --
-- Entity                                                                    --
-- ------------------------------------------------------------------------- --
entity LCDsteuerung is
  port (
    clk                  : in  std_logic;
    reset                : in  std_logic;
    -- Signale Funkuhr
    DCF_Enable_in        : in  std_logic;  -- Funkuhr ist eingeschaltet
    minute_Start_in      : in  std_logic;  -- Minuten-Signal wird empfangen
    states_in            : in  std_logic_vector(5 downto 0);
    -- Zeit und Datum
    timeAndDate_in : in std_logic_vector(43 downto 0);

    -- Daten, die auf dem Display dargestellt werden sollen
    data_Out             : out std_logic_vector(7 downto 0);
    data_mode_out        : out std_logic_vector(1 downto 0);
    data_Valid_out       : out std_logic;
    address_Col_out      : out std_logic_vector(5 downto 0);
    address_row_out      : out std_logic;
    display_on_out       : out std_logic;
    display_shift_out    : out std_logic_vector(1 downto 0);
    cursor_on_out        : out std_logic;
    cursor_blink_out     : out std_logic;
    nLCD_Driver_ready_in : in  std_logic
    );
end LCDsteuerung;

-- ------------------------------------------------------------------------- --
-- Architecture                                                              --
-- ------------------------------------------------------------------------- --
architecture a of LCDsteuerung is


  alias sec_Low_In  : std_logic_vector(3 downto 0) is timeAndDate_In(3 downto 0);
  alias sec_High_In : std_logic_vector(2 downto 0) is timeAndDate_In(6 downto 4);
  alias min_Low_In  : std_logic_vector(3 downto 0) is timeAndDate_In(10 downto 7);
  alias min_High_In : std_logic_vector(2 downto 0) is timeAndDate_In(13 downto 11);
  alias hour_Low_In    : std_logic_vector(3 downto 0) is timeAndDate_In(17 downto 14);
  alias hour_High_In   : std_logic_vector(1 downto 0) is timeAndDate_In(19 downto 18);
  alias day_Low_In     : std_logic_vector(3 downto 0) is timeAndDate_In(23 downto 20);
  alias day_High_in    : std_logic_vector(1 downto 0) is timeAndDate_In(25 downto 24);
  alias month_Low_In   : std_logic_vector(3 downto 0) is timeAndDate_In(29 downto 26);
  alias month_High_In  : std_logic                    is timeAndDate_In(30);
  alias year_Low_In    : std_logic_vector(3 downto 0) is timeAndDate_In(34 downto 31);
  alias year_High_In   : std_logic_vector(3 downto 0) is timeAndDate_In(38 downto 35);
  alias weekDay_In    : std_logic_vector(2 downto 0) is timeAndDate_In(41 downto 39);
  alias timezone_in : std_logic_vector(1 downto 0) is timeAndDate_in(43 downto 42);

  type state_t is (writeFrame, updateFrame, check, updateSecLow, updateSecHigh,
                   updateMinLow, updateMinHigh, updateHourLow, updateHourHigh,
                   updateDayLow, updateDayHigh, updateWeekday, updateTimezone,
                   updateMonthHigh, updateMonthLow, updateYearHigh,
                   updateYearLow, updateDCFenable, updateMinuteStart, updateStates);
  signal state_R, state_R_Next  : state_t;
  signal data_Out_Next          : std_logic_vector(7 downto 0);
  signal address_Col_out_next   : std_logic_vector(5 downto 0);
  signal address_row_out_next   : std_logic;
  signal data_mode_out_next     : std_logic_vector(1 downto 0);
  signal data_Valid_out_Next    : std_logic;
  signal cursor_on_out_next,
    cursor_blink_out_next,
    display_on_out_next         : std_logic;
  signal display_shift_out_next : std_logic_vector(1 downto 0);
  
  type   LCDdisplay_t is array (31 downto 0) of std_logic_vector(7 downto 0);
  type   LCDword4_t is array(3 downto 0) of std_logic_vector(7 downto 0);
  type   LCDword2_t is array (1 downto 0) of std_logic_vector(7 downto 0);
  signal timeFrame                           : LCDdisplay_t;
  signal Mo, Di, Mi, Do, Fr, Sa, So          : LCDword2_t;
  signal MEZ, MESZ, SET                      : LCDword4_t;
  signal dcf_Enable_R, dcf_Enable_R_Next     : std_logic;
  signal minute_Start_R, minute_Start_R_Next : std_logic;
  signal states_R, states_R_Next             : std_logic_vector(5 downto 0);
  signal sec_High_R, sec_High_R_Next         : std_logic_vector(2 downto 0);
  signal sec_Low_R, sec_Low_R_Next           : std_logic_vector(3 downto 0);
  signal min_High_R, min_High_R_Next         : std_logic_vector(2 downto 0);
  signal min_Low_R, min_Low_R_Next           : std_logic_vector(3 downto 0);
  signal hour_High_R, hour_High_R_Next       : std_logic_vector(1 downto 0);
  signal hour_Low_R, hour_Low_R_Next         : std_logic_vector(3 downto 0);
  signal weekday_R, weekday_R_Next           : std_logic_vector(2 downto 0);
  signal day_High_R, day_High_R_Next         : std_logic_vector(1 downto 0);
  signal day_Low_R, day_Low_R_Next           : std_logic_vector(3 downto 0);
  signal month_High_R, month_High_R_Next     : std_logic;
  signal month_Low_R, month_Low_R_Next       : std_logic_vector(3 downto 0);
  signal year_High_R, year_High_R_Next       : std_logic_vector(3 downto 0);
  signal year_Low_R, year_Low_R_Next         : std_logic_vector(3 downto 0);
  signal timezone_R, timezone_R_Next         : std_logic_vector(1 downto 0);
  signal update_Ready_R, update_Ready_R_Next : std_logic;
  signal write_Count_R, write_Count_R_Next   : integer range 0 to 31;
  
begin  -- a
  -- DATA
  -- | 0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15|
  -- +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  -- |                   0  0  :  0  0  :  0  0      |
  -- |          0  1  .  0  1  .  0  0               |
  -- +-----------------------------------------------|
  timeFrame(0)  <= x"20";               -- " "
  timeFrame(1)  <= x"20";               -- " "
  timeFrame(2)  <= x"20";               -- " "
  timeFrame(3)  <= x"20";               -- " "
  timeFrame(4)  <= x"20";               -- ":"
  timeFrame(5)  <= x"20";               -- " "
  timeFrame(6)  <= x"30";               -- "0"
  timeFrame(7)  <= x"30";               -- "0"
  timeFrame(8)  <= x"3A";               -- ":"
  timeFrame(9)  <= x"30";               -- "0"
  timeFrame(10) <= x"30";               -- "0"
  timeFrame(11) <= x"3A";               -- ":"
  timeFrame(12) <= x"30";               -- "0"
  timeFrame(13) <= x"30";               -- "0"
  timeFrame(14) <= x"20";               -- " "
  timeFrame(15) <= x"20";               -- " "

  timeFrame(16) <= x"20";               -- " "
  timeFrame(17) <= x"20";               -- " "
  timeFrame(18) <= x"20";               -- " "
  timeFrame(19) <= x"30";               -- "0"
  timeFrame(20) <= x"31";               -- "1"
  timeFrame(21) <= x"2E";               -- "."
  timeFrame(22) <= x"30";               -- "0"
  timeFrame(23) <= x"31";               -- "1"
  timeFrame(24) <= x"2E";               -- "."
  timeFrame(25) <= x"30";               -- "0"
  timeFrame(26) <= x"30";               -- "0"
  timeFrame(27) <= x"20";               -- " "
  timeFrame(28) <= x"20";               -- " "
  timeFrame(29) <= x"20";               -- " "
  timeFrame(30) <= x"20";               -- " "
  timeFrame(31) <= x"20";               -- " "

  MEZ(0) <= x"4D";                      -- "M"
  MEZ(1) <= x"45";                      -- "E"
  MEZ(2) <= x"5A";                      -- "Z"
  MEZ(3) <= x"20";                      -- " "

  MESZ(0) <= x"4D";                     -- "M"
  MESZ(1) <= x"45";                     -- "E"
  MESZ(2) <= x"53";                     -- "S"
  MESZ(3) <= x"5A";                     -- "Z"

  SET(0) <= x"53";                      -- "S"
  SET(1) <= x"45";                      -- "E"
  SET(2) <= x"54";                      -- "T"
  SET(3) <= x"20";                      -- " "

  Mo(0) <= x"4D";                       -- "M"
  Mo(1) <= x"6F";                       -- "o"

  Di(0) <= x"44";                       -- "D"
  Di(1) <= x"69";                       -- "i"

  Mi(0) <= x"4D";                       -- "M"
  Mi(1) <= x"69";                       -- "i"

  Do(0) <= x"44";                       -- "D"
  Do(1) <= x"6F";                       -- "o"

  Fr(0) <= x"46";                       -- "F"
  Fr(1) <= x"72";                       -- "r"

  Sa(0) <= x"53";                       -- "S"
  Sa(1) <= x"61";                       -- "a"

  So(0) <= x"53";                       -- "S"
  So(1) <= x"6F";                       -- "o"

  -- state Process
  process (day_High_R, day_High_in, day_Low_R, day_Low_in, dcf_Enable_R,
           hour_High_R, hour_High_in, hour_Low_R, hour_Low_in, min_High_R,
           min_High_in, min_Low_R, min_Low_in, minute_Start_R, minute_Start_in,
           month_High_R, month_High_in, month_Low_R, month_Low_in, sec_High_R,
           sec_High_in, sec_Low_R, sec_Low_in, state_R, states_R, states_in,
           timezone_R, timezone_in, update_Ready_R, weekday_R, weekday_in,
           year_High_R, year_High_in, year_Low_R, year_Low_in)
  begin  -- process
    state_R_Next <= state_R;
    case state_R is
      when writeFrame =>
        if update_Ready_R = '0' then
          state_R_Next <= writeFrame;
        else
          state_R_Next <= check;
        end if;
      when updateStates =>
        if update_Ready_R = '1' then
          if states_in(5 downto 4) = "10" then
            case states_in(3 downto 0) is
              when x"1" =>
                state_R_Next <= updateHourHigh;
              when x"2" =>
                state_R_Next <= updateHourLow;
              when x"3" =>
                state_R_Next <= updateMinHigh;
              when x"4" =>
                state_R_Next <= updateMinLow;
              when x"5" =>
                state_R_Next <= updateDayHigh;
              when x"6" =>
                state_R_Next <= updateDayLow;
              when x"7" =>
                state_R_Next <= updateMonthHigh;
              when x"8" =>
                state_R_Next <= updateMonthLow;
              when x"9" =>
                state_R_Next <= updateYearHigh;
              when x"A" =>
                state_R_Next <= updateYearLow;
              when x"B" =>
                state_R_Next <= updateWeekday;
              when others =>
                state_R_Next <= check;
            end case;
          else
            state_R_Next <= check;
          end if;
        else
          state_R_Next <= state_R;
        end if;
      when check =>
        if sec_Low_in /= sec_Low_R then
          state_R_Next <= updateSecLow;
        elsif sec_High_in /= sec_High_R then
          state_R_Next <= updateSecHigh;
        elsif min_Low_in /= min_Low_R then
          state_R_Next <= updateMinLow;
        elsif min_High_in /= min_High_R then
          state_R_Next <= updateMinHigh;
        elsif hour_Low_in /= hour_Low_R then
          state_R_Next <= updateHourLow;
        elsif hour_High_in /= hour_High_R then
          state_R_Next <= updateHourHigh;
        elsif weekday_in /= weekday_R then
          state_R_Next <= updateWeekday;
        elsif day_Low_in /= day_Low_R then
          state_R_Next <= updateDayLow;
        elsif day_High_in /= day_High_R then
          state_R_Next <= updateDayHigh;
        elsif month_Low_in /= month_Low_R then
          state_R_Next <= updateMonthLow;
        elsif month_High_in /= month_High_R then
          state_R_Next <= updateMonthHigh;
        elsif year_Low_in /= year_Low_R then
          state_R_Next <= updateYearLow;
        elsif year_High_in /= year_High_R then
          state_R_Next <= updateYearHigh;
        elsif timezone_in /= timezone_R then
          state_R_Next <= updateTimezone;
        elsif dcf_Enable_in /= dcf_Enable_R then
          state_R_Next <= updateDCFenable;
        elsif minute_Start_in /= minute_Start_R then
          state_R_Next <= updateMinuteStart;
        elsif states_in /= states_R then
          state_R_Next <= updateStates;
        else
          state_R_Next <= check;
        end if;
      when others =>
        if update_Ready_R = '1' then
          state_R_Next <= check;
        else
          state_R_Next <= state_R;
        end if;
    end case;
  end process;

-- output process
  process (DCF_Enable_in, Di, Do, Fr, MESZ, MEZ, Mi, Mo, Sa, So, day_High_R,
           day_High_in, day_Low_R, day_Low_in, dcf_Enable_R, hour_High_R,
           hour_High_in, hour_Low_R, hour_Low_in, min_High_R, min_High_in,
           min_Low_R, min_Low_in, minute_Start_R, minute_Start_in,
           month_High_R, month_High_in, month_Low_R, month_Low_in,
           nLCD_Driver_ready_in, sec_High_R, sec_High_in, sec_Low_R,
           sec_Low_in, set, state_R, states_R, states_in, timeFrame,
           timezone_R, timezone_in, update_Ready_R, weekday_R, weekday_in,
           write_Count_R, year_High_R, year_High_in, year_Low_R, year_Low_in)
  begin  -- process
    -- Ausgangssignale
    data_Out_Next          <= (others => '0');
    data_mode_out_next     <= (others => '0');
    address_row_out_next   <= '0';
    address_Col_out_next   <= (others => '0');
    data_Valid_out_Next    <= '0';
    display_on_out_next    <= '1';
    cursor_on_out_next     <= '0';
    cursor_blink_out_next  <= '0';
    display_shift_out_next <= "00";

    -- Register
    update_Ready_R_Next <= '0';

    write_Count_R_Next <= write_Count_R;

    sec_Low_R_Next      <= sec_Low_R;
    sec_High_R_Next     <= sec_High_R;
    min_Low_R_Next      <= min_Low_R;
    min_High_R_Next     <= min_High_R;
    hour_Low_R_Next     <= hour_Low_R;
    hour_High_R_Next    <= hour_High_R;
    weekday_R_Next      <= weekday_R;
    day_Low_R_Next      <= day_Low_R;
    day_High_R_Next     <= day_High_R;
    month_Low_R_Next    <= month_Low_R;
    month_High_R_Next   <= month_High_R;
    year_Low_R_Next     <= year_Low_R;
    year_High_R_Next    <= year_High_R;
    timezone_R_Next     <= timezone_R;
    dcf_Enable_R_Next   <= dcf_Enable_R;
    minute_Start_R_Next <= minute_Start_R;
    states_R_Next       <= states_R;
    if states_in(5 downto 4) = "10"  then
      cursor_blink_out_next <= '1';
      cursor_on_out_next    <= '1';
    end if;
    case state_R is
      when check =>
        write_Count_R_Next <= 0;
      when writeFrame =>
        -- Addresse
        if write_Count_R > 16 then
          address_row_out_next <= '1';
        else
          address_row_out_next <= '0';
        end if;
        address_Col_out_next <= conv_std_logic_vector(write_Count_R rem 16, 6);
        -- Daten
        data_mode_out_next   <= "00";   -- Codierung: ASCII-Zeichen
        data_Out_Next        <= timeFrame(write_Count_R);  -- Zeichen
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          data_Valid_out_Next <= '1';
          if write_Count_r = 31 then
            sec_Low_R_Next      <= (others => '0');
            sec_High_R_Next     <= (others => '0');
            min_Low_R_Next      <= (others => '0');
            min_High_R_Next     <= (others => '0');
            hour_Low_R_Next     <= (others => '0');
            hour_High_R_Next    <= (others => '0');
            weekday_R_Next      <= (others => '0');
            day_Low_R_Next      <= (others => '0');
            day_High_R_Next     <= (others => '0');
            month_Low_R_Next    <= (others => '0');
            month_High_R_Next   <= '0';
            year_Low_R_Next     <= (others => '0');
            year_High_R_Next    <= (others => '0');
            timezone_R_Next     <= (others => '0');
            dcf_Enable_R_Next   <= '0';
            minute_Start_R_Next <= '0';
            states_R_Next       <= (others => '0');

            update_Ready_R_Next <= '1';
            write_Count_R_Next  <= 0;
          else
            write_Count_R_Next <= write_Count_R + 1;
          end if;
        end if;
      when updateStates =>
        address_row_out_next <= '0';
        address_Col_out_next <= conv_std_logic_vector(write_Count_r, 6);
        data_mode_out_next   <= "00";   -- Codierung: ASCII-Zeichen
        if states_in(5 downto 4) = "10" then
          data_Out_Next(7 downto 0) <= set(write_Count_r);  -- Zeichen
        else
          data_Out_Next(7 downto 0) <= x"20";               -- Zeichen
        end if;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          data_Valid_out_Next <= '1';
          if write_Count_r = 3 then
            states_R_Next       <= states_in;
            update_Ready_R_Next <= '1';
            write_Count_R_Next  <= 0;
          else
            write_Count_R_Next <= write_Count_r + 1;
          end if;
        end if;
      when updateSecLow =>
        address_Col_out_next(3 downto 0) <= x"D";           -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(3 downto 0)        <= sec_Low_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          sec_Low_R_Next      <= sec_Low_in;
          data_Valid_out_Next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when updateSecHigh =>
        address_Col_out_next(3 downto 0) <= x"C";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(2 downto 0)        <= sec_High_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          sec_High_R_Next     <= sec_High_in;
          data_Valid_out_Next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when updateMinLow =>
        address_Col_out_next(3 downto 0) <= x"A";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(3 downto 0)        <= min_Low_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0'then
          min_Low_R_Next      <= min_Low_in;
          data_Valid_out_Next <= '1';
          update_Ready_R_Next <= '1';
        end if;

      when updateMinHigh =>
        address_Col_out_next(3 downto 0) <= x"9";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(2 downto 0)        <= min_High_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          min_High_R_Next     <= min_High_in;
          data_Valid_out_Next <= '1';
          update_Ready_R_Next <= '1';
        end if;

      when updateHourLow =>
        address_Col_out_next(3 downto 0) <= x"7";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(3 downto 0)        <= hour_Low_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          hour_Low_R_Next     <= hour_Low_in;
          data_Valid_out_Next <= '1';
          update_Ready_R_Next <= '1';
        end if;

      when updateHourHigh =>
        address_Col_out_next(3 downto 0) <= x"6";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(1 downto 0)        <= hour_High_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          hour_High_R_Next    <= hour_High_in;
          data_Valid_out_Next <= '1';
          update_Ready_R_Next <= '1';
        end if;

      when updateWeekday =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= conv_std_logic_vector(write_Count_r, 4);  -- Adresse
        case weekday_in is
          when "001"  => data_Out_Next <= Mo(write_count_R);
          when "010"  => data_Out_Next <= Di(write_count_R);
          when "011"  => data_Out_Next <= Mi(write_count_R);
          when "100"  => data_Out_Next <= Do(write_count_R);
          when "101"  => data_Out_Next <= Fr(write_count_R);
          when "110"  => data_Out_Next <= Sa(write_count_R);
          when "111"  => data_Out_Next <= So(write_count_R);
          when others => data_Out_Next <= x"20";  -- " "
        end case;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          if write_count_R = 1 then
            update_Ready_R_Next <= '1';
            weekday_R_Next      <= weekday_in;
            write_count_R_Next  <= 0;
            data_Valid_out_next <= '1';
          else
            data_Valid_out_next <= '1';
            write_count_R_Next  <= write_count_R + 1;
          end if;
        end if;
        

      when updateDayLow =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= x"4";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(3 downto 0)        <= day_Low_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          day_Low_R_Next      <= day_Low_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;

      when updateDayHigh =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= x"3";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(1 downto 0)        <= day_High_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          day_High_R_Next     <= day_High_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;

      when updateMonthLow =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= x"7";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(3 downto 0)        <= month_Low_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          month_Low_R_Next    <= month_Low_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when updateMonthHigh =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= x"6";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(0)                 <= month_High_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          month_High_R_Next   <= month_High_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when updateYearLow =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= x"A";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(3 downto 0)        <= year_Low_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          year_Low_R_Next     <= year_Low_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when updateYearHigh =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= x"9";  -- Adresse
        data_mode_out_next               <= "10";
        data_Out_Next(3 downto 0)        <= year_High_in;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          year_High_R_Next    <= year_High_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when updateTimezone =>
        address_Col_out_next(3 downto 0) <= conv_std_logic_vector(write_count_R, 4);  -- Adresse
        data_mode_out_next               <= "00";
        if timezone_in = "01" then
          data_Out_Next(7 downto 0) <= MESZ(write_count_R);  -- Zeichen
        elsif timezone_in = "10" then
          data_Out_Next(7 downto 0) <= MEZ(write_count_R);   -- Zeichen
        else
          data_Out_Next(7 downto 0) <= x"FF";                -- Zeichen
        end if;

        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          data_Valid_out_next <= '1';
          if write_count_R = 3 then
            update_Ready_R_Next <= '1';
            timezone_R_Next     <= timezone_in;
            write_count_R_Next  <= 0;
          else
            write_count_R_Next <= write_count_R + 1;
          end if;
        end if;
        
      when updateDCFenable =>
        address_Col_out_next(3 downto 0) <= x"F"; 
        data_mode_out_next               <= "00";  -- Codierung: ASCII-Zeichen
        if DCF_Enable_in = '1' then
          data_Out_Next(7 downto 0) <= x"FA";      -- Zeichen
        else
          data_Out_Next(7 downto 0) <= x"20";      -- Zeichen (Leerzeichen)
        end if;

        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          dcf_Enable_R_Next   <= DCF_Enable_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when updateMinuteStart =>
        address_row_out_next             <= '1';
        address_Col_out_next(3 downto 0) <= x"F";      
        data_mode_out_next               <= "00";
        if minute_Start_in = '1' then
          data_Out_Next(7 downto 0) <= x"6D";
        else
          data_Out_Next(7 downto 0) <= x"20";
        end if;
        if nLCD_Driver_ready_in = '0' and update_Ready_R = '0' then
          minute_Start_R_Next <= minute_Start_in;
          data_Valid_out_next <= '1';
          update_Ready_R_Next <= '1';
        end if;
        
      when others =>
        update_Ready_R_Next <= '1';
    end case;
  end process;

-- register
  process (clk, reset)
  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)     
      data_Out          <= (others => '0');
      data_mode_out     <= (others => '0');
      data_Valid_out    <= '0';
      address_row_out   <= '0';
      address_Col_out   <= (others => '0');
      display_on_out    <= '0';
      display_shift_out <= "00";
      cursor_on_out     <= '0';
      cursor_blink_out  <= '0';

      sec_Low_R      <= (others => '0');
      sec_High_R     <= (others => '0');
      min_Low_R      <= (others => '0');
      min_High_R     <= (others => '0');
      hour_Low_R     <= (others => '0');
      hour_High_R    <= (others => '0');
      weekday_R      <= (others => '0');
      day_Low_R      <= "0001";
      day_High_R     <= (others => '0');
      month_Low_R    <= "0001";
      month_High_R   <= '0';
      year_Low_R     <= (others => '0');
      year_High_R    <= (others => '0');
      timezone_R     <= (others => '0');
      dcf_Enable_R   <= '0';
      minute_Start_R <= '0';
      states_R       <= (others => '0');
      state_R        <= writeFrame;

      write_count_R  <= 0;
      update_Ready_R <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      data_Out          <= data_Out_Next;
      data_mode_out     <= data_mode_out_next;
      data_Valid_out    <= data_Valid_out_next;
      address_row_out   <= address_row_out_next;
      address_Col_out   <= address_Col_out_next;
      display_on_out    <= display_on_out_next;
      display_shift_out <= display_shift_out_next;
      cursor_on_out     <= cursor_on_out_next;
      cursor_blink_out  <= cursor_blink_out_next;

      sec_Low_R      <= sec_Low_R_Next;
      sec_High_R     <= sec_High_R_Next;
      min_Low_R      <= min_Low_R_Next;
      min_High_R     <= min_High_R_Next;
      hour_Low_R     <= hour_Low_R_Next;
      hour_High_R    <= hour_High_R_Next;
      weekday_R      <= weekday_R_Next;
      day_Low_R      <= day_Low_R_Next;
      day_High_R     <= day_High_R_Next;
      month_Low_R    <= month_Low_R_Next;
      month_High_R   <= month_High_R_Next;
      year_Low_R     <= year_Low_R_Next;
      year_High_R    <= year_High_R_Next;
      timezone_R     <= timezone_R_Next;
      dcf_Enable_R   <= dcf_Enable_R_Next;
      minute_Start_R <= minute_Start_R_Next;
      states_R       <= states_R_Next;

      state_r        <= state_R_Next;
      write_count_R  <= write_count_R_Next;
      update_Ready_R <= update_Ready_R_Next;
    end if;
  end process;
end a;
