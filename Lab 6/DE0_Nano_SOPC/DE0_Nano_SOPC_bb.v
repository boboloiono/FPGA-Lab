
module DE0_Nano_SOPC (
	altpll_sdram,
	altpll_sys_c3_out,
	locked_from_the_altpll_sys,
	clk_50,
	reset_n,
	epcs_flash_controller_0_external_dclk,
	epcs_flash_controller_0_external_sce,
	epcs_flash_controller_0_external_sdo,
	epcs_flash_controller_0_external_data0,
	in_port_to_the_key,
	lcd_reset_n_external_connection_export,
	out_port_from_the_led,
	lt24_controller_0_conduit_end_cs,
	lt24_controller_0_conduit_end_rs,
	lt24_controller_0_conduit_end_rd,
	lt24_controller_0_conduit_end_wr,
	lt24_controller_0_conduit_end_data,
	zs_addr_from_the_sdram,
	zs_ba_from_the_sdram,
	zs_cas_n_from_the_sdram,
	zs_cke_from_the_sdram,
	zs_cs_n_from_the_sdram,
	zs_dq_to_and_from_the_sdram,
	zs_dqm_from_the_sdram,
	zs_ras_n_from_the_sdram,
	zs_we_n_from_the_sdram,
	in_port_to_the_sw,
	touch_panel_busy_external_connection_export,
	touch_panel_pen_irq_n_external_connection_export,
	touch_panel_spi_external_MISO,
	touch_panel_spi_external_MOSI,
	touch_panel_spi_external_SCLK,
	touch_panel_spi_external_SS_n);	

	output		altpll_sdram;
	output		altpll_sys_c3_out;
	output		locked_from_the_altpll_sys;
	input		clk_50;
	input		reset_n;
	output		epcs_flash_controller_0_external_dclk;
	output		epcs_flash_controller_0_external_sce;
	output		epcs_flash_controller_0_external_sdo;
	input		epcs_flash_controller_0_external_data0;
	input	[1:0]	in_port_to_the_key;
	output		lcd_reset_n_external_connection_export;
	output	[7:0]	out_port_from_the_led;
	output		lt24_controller_0_conduit_end_cs;
	output		lt24_controller_0_conduit_end_rs;
	output		lt24_controller_0_conduit_end_rd;
	output		lt24_controller_0_conduit_end_wr;
	output	[15:0]	lt24_controller_0_conduit_end_data;
	output	[12:0]	zs_addr_from_the_sdram;
	output	[1:0]	zs_ba_from_the_sdram;
	output		zs_cas_n_from_the_sdram;
	output		zs_cke_from_the_sdram;
	output		zs_cs_n_from_the_sdram;
	inout	[15:0]	zs_dq_to_and_from_the_sdram;
	output	[1:0]	zs_dqm_from_the_sdram;
	output		zs_ras_n_from_the_sdram;
	output		zs_we_n_from_the_sdram;
	input	[3:0]	in_port_to_the_sw;
	input		touch_panel_busy_external_connection_export;
	input		touch_panel_pen_irq_n_external_connection_export;
	input		touch_panel_spi_external_MISO;
	output		touch_panel_spi_external_MOSI;
	output		touch_panel_spi_external_SCLK;
	output		touch_panel_spi_external_SS_n;
endmodule
