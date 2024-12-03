	component DE0_Nano_SOPC is
		port (
			altpll_sdram                                     : out   std_logic;                                        -- clk
			altpll_sys_c3_out                                : out   std_logic;                                        -- clk
			locked_from_the_altpll_sys                       : out   std_logic;                                        -- export
			clk_50                                           : in    std_logic                     := 'X';             -- clk
			reset_n                                          : in    std_logic                     := 'X';             -- reset_n
			epcs_flash_controller_0_external_dclk            : out   std_logic;                                        -- dclk
			epcs_flash_controller_0_external_sce             : out   std_logic;                                        -- sce
			epcs_flash_controller_0_external_sdo             : out   std_logic;                                        -- sdo
			epcs_flash_controller_0_external_data0           : in    std_logic                     := 'X';             -- data0
			in_port_to_the_key                               : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			lcd_reset_n_external_connection_export           : out   std_logic;                                        -- export
			out_port_from_the_led                            : out   std_logic_vector(7 downto 0);                     -- export
			lt24_controller_0_conduit_end_cs                 : out   std_logic;                                        -- cs
			lt24_controller_0_conduit_end_rs                 : out   std_logic;                                        -- rs
			lt24_controller_0_conduit_end_rd                 : out   std_logic;                                        -- rd
			lt24_controller_0_conduit_end_wr                 : out   std_logic;                                        -- wr
			lt24_controller_0_conduit_end_data               : out   std_logic_vector(15 downto 0);                    -- data
			zs_addr_from_the_sdram                           : out   std_logic_vector(12 downto 0);                    -- addr
			zs_ba_from_the_sdram                             : out   std_logic_vector(1 downto 0);                     -- ba
			zs_cas_n_from_the_sdram                          : out   std_logic;                                        -- cas_n
			zs_cke_from_the_sdram                            : out   std_logic;                                        -- cke
			zs_cs_n_from_the_sdram                           : out   std_logic;                                        -- cs_n
			zs_dq_to_and_from_the_sdram                      : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			zs_dqm_from_the_sdram                            : out   std_logic_vector(1 downto 0);                     -- dqm
			zs_ras_n_from_the_sdram                          : out   std_logic;                                        -- ras_n
			zs_we_n_from_the_sdram                           : out   std_logic;                                        -- we_n
			in_port_to_the_sw                                : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			touch_panel_busy_external_connection_export      : in    std_logic                     := 'X';             -- export
			touch_panel_pen_irq_n_external_connection_export : in    std_logic                     := 'X';             -- export
			touch_panel_spi_external_MISO                    : in    std_logic                     := 'X';             -- MISO
			touch_panel_spi_external_MOSI                    : out   std_logic;                                        -- MOSI
			touch_panel_spi_external_SCLK                    : out   std_logic;                                        -- SCLK
			touch_panel_spi_external_SS_n                    : out   std_logic                                         -- SS_n
		);
	end component DE0_Nano_SOPC;

	u0 : component DE0_Nano_SOPC
		port map (
			altpll_sdram                                     => CONNECTED_TO_altpll_sdram,                                     --                             altpll_sys_c1.clk
			altpll_sys_c3_out                                => CONNECTED_TO_altpll_sys_c3_out,                                --                             altpll_sys_c3.clk
			locked_from_the_altpll_sys                       => CONNECTED_TO_locked_from_the_altpll_sys,                       --                 altpll_sys_locked_conduit.export
			clk_50                                           => CONNECTED_TO_clk_50,                                           --                             clk_50_clk_in.clk
			reset_n                                          => CONNECTED_TO_reset_n,                                          --                       clk_50_clk_in_reset.reset_n
			epcs_flash_controller_0_external_dclk            => CONNECTED_TO_epcs_flash_controller_0_external_dclk,            --          epcs_flash_controller_0_external.dclk
			epcs_flash_controller_0_external_sce             => CONNECTED_TO_epcs_flash_controller_0_external_sce,             --                                          .sce
			epcs_flash_controller_0_external_sdo             => CONNECTED_TO_epcs_flash_controller_0_external_sdo,             --                                          .sdo
			epcs_flash_controller_0_external_data0           => CONNECTED_TO_epcs_flash_controller_0_external_data0,           --                                          .data0
			in_port_to_the_key                               => CONNECTED_TO_in_port_to_the_key,                               --                   key_external_connection.export
			lcd_reset_n_external_connection_export           => CONNECTED_TO_lcd_reset_n_external_connection_export,           --           lcd_reset_n_external_connection.export
			out_port_from_the_led                            => CONNECTED_TO_out_port_from_the_led,                            --                   led_external_connection.export
			lt24_controller_0_conduit_end_cs                 => CONNECTED_TO_lt24_controller_0_conduit_end_cs,                 --             lt24_controller_0_conduit_end.cs
			lt24_controller_0_conduit_end_rs                 => CONNECTED_TO_lt24_controller_0_conduit_end_rs,                 --                                          .rs
			lt24_controller_0_conduit_end_rd                 => CONNECTED_TO_lt24_controller_0_conduit_end_rd,                 --                                          .rd
			lt24_controller_0_conduit_end_wr                 => CONNECTED_TO_lt24_controller_0_conduit_end_wr,                 --                                          .wr
			lt24_controller_0_conduit_end_data               => CONNECTED_TO_lt24_controller_0_conduit_end_data,               --                                          .data
			zs_addr_from_the_sdram                           => CONNECTED_TO_zs_addr_from_the_sdram,                           --                                sdram_wire.addr
			zs_ba_from_the_sdram                             => CONNECTED_TO_zs_ba_from_the_sdram,                             --                                          .ba
			zs_cas_n_from_the_sdram                          => CONNECTED_TO_zs_cas_n_from_the_sdram,                          --                                          .cas_n
			zs_cke_from_the_sdram                            => CONNECTED_TO_zs_cke_from_the_sdram,                            --                                          .cke
			zs_cs_n_from_the_sdram                           => CONNECTED_TO_zs_cs_n_from_the_sdram,                           --                                          .cs_n
			zs_dq_to_and_from_the_sdram                      => CONNECTED_TO_zs_dq_to_and_from_the_sdram,                      --                                          .dq
			zs_dqm_from_the_sdram                            => CONNECTED_TO_zs_dqm_from_the_sdram,                            --                                          .dqm
			zs_ras_n_from_the_sdram                          => CONNECTED_TO_zs_ras_n_from_the_sdram,                          --                                          .ras_n
			zs_we_n_from_the_sdram                           => CONNECTED_TO_zs_we_n_from_the_sdram,                           --                                          .we_n
			in_port_to_the_sw                                => CONNECTED_TO_in_port_to_the_sw,                                --                    sw_external_connection.export
			touch_panel_busy_external_connection_export      => CONNECTED_TO_touch_panel_busy_external_connection_export,      --      touch_panel_busy_external_connection.export
			touch_panel_pen_irq_n_external_connection_export => CONNECTED_TO_touch_panel_pen_irq_n_external_connection_export, -- touch_panel_pen_irq_n_external_connection.export
			touch_panel_spi_external_MISO                    => CONNECTED_TO_touch_panel_spi_external_MISO,                    --                  touch_panel_spi_external.MISO
			touch_panel_spi_external_MOSI                    => CONNECTED_TO_touch_panel_spi_external_MOSI,                    --                                          .MOSI
			touch_panel_spi_external_SCLK                    => CONNECTED_TO_touch_panel_spi_external_SCLK,                    --                                          .SCLK
			touch_panel_spi_external_SS_n                    => CONNECTED_TO_touch_panel_spi_external_SS_n                     --                                          .SS_n
		);

