/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : top_board
 * Target : Gowin GW5A-LV25 (Tang Primer 25K)
 * Description : Physical Top-Level for the PicoRV32 SoC Project.
 * Maps the internal 'main_system' signals to physical FPGA pins (IOs).
 * Handles global clock distribution, dynamic clock switching, and
 * system-wide reset generation.
 *
 * ============================================================================
 * Hardware Resources & Connectivity:
 * - Clock Source : 50 MHz external oscillator input.
 * - Reset System : Managed by 'reset_control' using physical button 'btn0'.
 * - Debug IOs    : LEDs and Buttons (btn1).
 * - Peripherals  : UART (Serial), PMODs (GPIO/DVI), and SPI SD-Card.
 * - Video Output : HDMI/DVI via TMDS signaling on PMOD pins.
 * ============================================================================
 * Key Features:
 * 1. Dynamic Clock Switching: Uses the 'Gowin_DCS' primitive to safely 
 * switch the main CPU 'clk' between 24, 48, 60, and 120 MHz at runtime 
 * based on the 'clkreg' value from the system configuration.
 * 2. Protection: Includes an 'ifdef' check for project-wide configuration 
 * constants defined in "config.vh".
 * 3. Modular Design: Encapsulates the core SoC within 'main_system', 
 * allowing for easier physical porting to different FPGA boards.
 * ============================================================================
 */
`include "config.vh"


`ifndef CONFIG_V
`error "config.v must be read in first of the projet!"
`endif


module top_board (
            input wire        clk50,

            input wire        btn0,   // reset button
            input wire        btn1,

            input wire        uart_rx,
            output wire       uart_tx,

            output wire       led0,
            output wire       led1,

            // pmod2
            output wire [7:0] pmod2,

            // pmod1
            output              tmds_clk_n,
            output              tmds_clk_p,
            output [2:0]        tmds_data_n,
            output [2:0]        tmds_data_p,
                
            // pmod0
            input wire          i_analog1p,
            input wire          i_analog1n,
            input wire          i_analog2p,
            input wire          i_analog2n,
            input wire          i_analog3p,
            input wire          i_analog3n
            //input wire          joy_btn;
            );


    wire [1:0] clkreg; 
    wire clk, clk_hdmi_x5, clk_hdmi, clk60, clk48, clk24;

    clk_producer #(
    ) clk_producer_inst0 (
        .clk27(clk27),
        .clk50(clk50),

        .clk_hdmi_x5(clk_hdmi_x5),
        .clk_hdmi(clk_hdmi),

        .clk60(clk60),
        .clk48(clk48),
        .clk24(clk24),

        .clk_ready(clk_ready)
    );


    Gowin_DCS dcs0(
        .clkout(clk), //output clkout
        .clkreg(clkreg), //input [1:0] clkreg
        .clkin0(clk24), //input clkin0
        .clkin1(clk48), //input clkin1
        .clkin2(clk60), //input clkin2
        .clkin3(clk_hdmi) //input clkin3
    );

    wire reset_n; 

    reset_control reset_control_inst0 (
        .clk(clk),
        .reset_button_n(~btn0),
        .reset_n(reset_n)
    );

    assign led0 =  1'b0;
    assign led1 =  1'b0;

    wire [7:0] leds_o;

   //assign leds = ~leds_data_o[5:0]; // Connect to the LEDs off the FPGA
   assign pmod2 = ~leds_o;

    main_system (
        .reset_n(reset_n),

        .clk(clk),
        .clk24(clk24),
        .clk_pixel(clk_hdmi),
        .clk_pixel_x5(clk_hdmi_x5),

        .clkreg(clkreg),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
       
        .tmds_clk_n(tmds_clk_n),
        .tmds_clk_p(tmds_clk_p),
        .tmds_data_n(tmds_data_n),
        .tmds_data_p(tmds_data_p),

        .port_in(),
        .port_out(leds_o),
                
/*
        .ddram_a(ddram_a),
        .ddram_ba(ddram_ba),
        .ddram_cas_n(ddram_cas_n),
        .ddram_cke(ddram_cke),
        .ddram_clk_p(ddram_clk_p),
        .ddram_cs_n(ddram_cs_n),
        .ddram_dm(ddram_dm),
        .ddram_dq(ddram_dq),
        .ddram_dqs_n(ddram_dqs_n),
        .ddram_dqs_p(ddram_dqs_p),
        .ddram_odt(ddram_odt),
        .ddram_ras_n(ddram_ras_n),
        .ddram_reset_n(ddram_reset_n),
        .ddram_we_n(ddram_we_n),
*/

        .spisdcard_clk(spisdcard_clk),
        .spisdcard_cs_n(spisdcard_cs_n),
        .spisdcard_miso(spisdcard_miso),
        .spisdcard_mosi(spisdcard_mosi)
    );





/*
    bus32_adc adc0 (
        .clk(clk),
        .clk_50(clk50),
        .reset_n(reset_n),
        .adc_sel(adc_bus_sel),
        .addr(mem_addr[3:0]),
        .wstrb(mem_wstrb),
        .data_i(mem_wdata),
        .ready(adc_bus_ready),
        .data_o(adc_bus_data_o),

        .i_analog1p(i_analog1p),
        .i_analog1n(i_analog1n),
        .i_analog2p(i_analog2p),
        .i_analog2n(i_analog2n),
        .i_analog3p(i_analog3p),
        .i_analog3n(i_analog3n)
    );
*/


endmodule
