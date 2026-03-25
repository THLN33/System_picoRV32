/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module : top_board
 * Target : Gowin GW2A-LV18 (Tang Primer 20K) 
 * Description : Physical Top-Level for the PicoRV32 SoC Project.
 * Maps the internal 'main_system' signals to physical FPGA pins (IOs).
 * Handles global clock distribution, dynamic clock switching, and
 * system-wide reset generation.
 *
 * ============================================================================
 * Hardware Resources & Connectivity:
 * - Clock Source : 27 MHz external oscillator input.
 * - Reset System : Managed by 'reset_control' using physical button 'btn0'.
 * - Debug IOs    : LEDs and Buttons (btn1).
 * - Peripherals  : UART (Serial), PMODs (GPIO), and SPI SD-Card.
 * - Video Output : HDMI/DVI via TMDS signaling.
 * ============================================================================
 * Key Features:
 * 1. Dynamic Clock Switching: Uses the 'Gowin_DCS' primitive to safely 
 * switch the main CPU 'clk' between 24, 48 and 60 MHz at runtime 
 * based on the 'clkreg' value from the system configuration.
 * 2. Protection: Includes an 'ifdef' check for project-wide configuration 
 * constants defined in "config.vh".
 * 3. Modular Design: Encapsulates the core SoC within 'main_system', 
 * allowing for easier physical porting to different FPGA boards.
 * ============================================================================
 */
`include "config.vh"


`ifndef CONFIG_V
`error "config.v must be read before main_system.v"
`endif

module top_board (
            input wire        clk27,

            input wire        uart_rx,
            output wire       uart_tx,

            input wire        btn_n0,   // reset button
            input wire        btn_n1,
            input wire        btn_n2,
            input wire        btn_n3,
            input wire        btn_n4,

            output wire       led0,
            output wire       led1,
            output wire       led2,
            output wire       led3,
            output wire       led4,
            output wire       led5,

            inout wire [7:0] pmod0,
            inout wire [7:0] pmod1,
            inout wire [7:0] pmod2,
   
            output              tmds_clk_n,
            output              tmds_clk_p,
            output [2:0]        tmds_data_n,
            output [2:0]        tmds_data_p,


            output wire   [13:0] ddram_a,
            output wire    [2:0] ddram_ba,
            output wire          ddram_cas_n,
            output wire          ddram_cke,
            //output wire          ddram_clk_n,
            output wire          ddram_clk_p,
            output wire          ddram_cs_n,
            output wire    [1:0] ddram_dm,
            inout  wire   [15:0] ddram_dq,
            inout  wire    [1:0] ddram_dqs_n,
            inout  wire    [1:0] ddram_dqs_p,
            output wire          ddram_odt,
            output wire          ddram_ras_n,
            output wire          ddram_reset_n,
            output wire          ddram_we_n,

            output reg           spisdcard_clk,
            output reg           spisdcard_cs_n,
            input  wire          spisdcard_miso,
            output reg           spisdcard_mosi
            );

    wire [1:0] clkreg; 
    wire clk, clk_hdmi_x5, clk_hdmi, clk60, clk48, clk24;

    wire clk_ready;

    clk_producer #(
        .HDMI_IDIV(`HDMI_PLL_IDIV),
        .HDMI_M(`HDMI_PLL_M),
        .HDMI_N(`HDMI_PLL_N)
    ) clk_producer_inst0 (
        .clk27(clk27),
        .clk50(clk50),

        .clk_hdmi_x5(clk_hdmi_x5),
        .clk_hdmi(clk_hdmi),

        .clk24(clk24),
        .clk48(clk48),
        .clk60(clk60),

        .clk_ready(clk_ready)
    );

    
    //assign clk = clk60;

    Gowin_DCS dcs0(
        .clkout(clk), //output clkout
        .clkreg(clkreg), //input [1:0] clkreg
        .clkin0(clk24), //input clkin0
        .clkin1(clk48), //input clkin1
        .clkin2(clk60), //input clkin2
        .clkin3(clk_hdmi) //input clkin3
    );


    assign led0 =  1'b0;
    assign led1 =  1'b0;

    wire                       reset_n; 

    reset_control reset_control_inst0 (
        .clk(clk),
        .reset_button_n(btn_n0),
        .reset_n(reset_n)
    );

    wire [7:0] leds_o;

    main_system (
        .clk(clk),
        .reset_n(reset_n),

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

        .spisdcard_clk(spisdcard_clk),
        .spisdcard_cs_n(spisdcard_cs_n),
        .spisdcard_miso(spisdcard_miso),
        .spisdcard_mosi(spisdcard_mosi)
    );


   //assign leds = ~leds_data_o[5:0]; // Connect to the LEDs off the FPGA
   assign pmod0 = ~leds_o;

endmodule   // top_board
