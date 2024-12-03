	DE0_Nano_SOPC u0 (
		.altpll_sdram                                     (<connected-to-altpll_sdram>),                                     //                             altpll_sys_c1.clk
		.altpll_sys_c3_out                                (<connected-to-altpll_sys_c3_out>),                                //                             altpll_sys_c3.clk
		.locked_from_the_altpll_sys                       (<connected-to-locked_from_the_altpll_sys>),                       //                 altpll_sys_locked_conduit.export
		.clk_50                                           (<connected-to-clk_50>),                                           //                             clk_50_clk_in.clk
		.reset_n                                          (<connected-to-reset_n>),                                          //                       clk_50_clk_in_reset.reset_n
		.epcs_flash_controller_0_external_dclk            (<connected-to-epcs_flash_controller_0_external_dclk>),            //          epcs_flash_controller_0_external.dclk
		.epcs_flash_controller_0_external_sce             (<connected-to-epcs_flash_controller_0_external_sce>),             //                                          .sce
		.epcs_flash_controller_0_external_sdo             (<connected-to-epcs_flash_controller_0_external_sdo>),             //                                          .sdo
		.epcs_flash_controller_0_external_data0           (<connected-to-epcs_flash_controller_0_external_data0>),           //                                          .data0
		.in_port_to_the_key                               (<connected-to-in_port_to_the_key>),                               //                   key_external_connection.export
		.lcd_reset_n_external_connection_export           (<connected-to-lcd_reset_n_external_connection_export>),           //           lcd_reset_n_external_connection.export
		.out_port_from_the_led                            (<connected-to-out_port_from_the_led>),                            //                   led_external_connection.export
		.lt24_controller_0_conduit_end_cs                 (<connected-to-lt24_controller_0_conduit_end_cs>),                 //             lt24_controller_0_conduit_end.cs
		.lt24_controller_0_conduit_end_rs                 (<connected-to-lt24_controller_0_conduit_end_rs>),                 //                                          .rs
		.lt24_controller_0_conduit_end_rd                 (<connected-to-lt24_controller_0_conduit_end_rd>),                 //                                          .rd
		.lt24_controller_0_conduit_end_wr                 (<connected-to-lt24_controller_0_conduit_end_wr>),                 //                                          .wr
		.lt24_controller_0_conduit_end_data               (<connected-to-lt24_controller_0_conduit_end_data>),               //                                          .data
		.zs_addr_from_the_sdram                           (<connected-to-zs_addr_from_the_sdram>),                           //                                sdram_wire.addr
		.zs_ba_from_the_sdram                             (<connected-to-zs_ba_from_the_sdram>),                             //                                          .ba
		.zs_cas_n_from_the_sdram                          (<connected-to-zs_cas_n_from_the_sdram>),                          //                                          .cas_n
		.zs_cke_from_the_sdram                            (<connected-to-zs_cke_from_the_sdram>),                            //                                          .cke
		.zs_cs_n_from_the_sdram                           (<connected-to-zs_cs_n_from_the_sdram>),                           //                                          .cs_n
		.zs_dq_to_and_from_the_sdram                      (<connected-to-zs_dq_to_and_from_the_sdram>),                      //                                          .dq
		.zs_dqm_from_the_sdram                            (<connected-to-zs_dqm_from_the_sdram>),                            //                                          .dqm
		.zs_ras_n_from_the_sdram                          (<connected-to-zs_ras_n_from_the_sdram>),                          //                                          .ras_n
		.zs_we_n_from_the_sdram                           (<connected-to-zs_we_n_from_the_sdram>),                           //                                          .we_n
		.in_port_to_the_sw                                (<connected-to-in_port_to_the_sw>),                                //                    sw_external_connection.export
		.touch_panel_busy_external_connection_export      (<connected-to-touch_panel_busy_external_connection_export>),      //      touch_panel_busy_external_connection.export
		.touch_panel_pen_irq_n_external_connection_export (<connected-to-touch_panel_pen_irq_n_external_connection_export>), // touch_panel_pen_irq_n_external_connection.export
		.touch_panel_spi_external_MISO                    (<connected-to-touch_panel_spi_external_MISO>),                    //                  touch_panel_spi_external.MISO
		.touch_panel_spi_external_MOSI                    (<connected-to-touch_panel_spi_external_MOSI>),                    //                                          .MOSI
		.touch_panel_spi_external_SCLK                    (<connected-to-touch_panel_spi_external_SCLK>),                    //                                          .SCLK
		.touch_panel_spi_external_SS_n                    (<connected-to-touch_panel_spi_external_SS_n>)                     //                                          .SS_n
	);

