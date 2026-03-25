/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : top_board
 * Target : Gowin GW2AR-LV18 (Tang Nano 20K) 
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
 * - Peripherals  : UART (Serial), GPIO (LED), and SPI SD-Card.
 * - Video Output : HDMI/DVI via TMDS signaling.
 * ============================================================================
 * Key Features:
 * 1. Dynamic Clock Switching: Uses the 'Gowin_DCS' primitive to safely 
 * switch the main CPU 'clk' between 24 and 48 MHz at runtime 
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
            input wire        clk50,

            input wire        uart_rx,
            output wire       uart_tx,

            input wire        btn0,   // reset button 
            input wire        btn1,


            output wire [5:0]   leds,
 
            output              tmds_clk_n,
            output              tmds_clk_p,
            output [2:0]        tmds_data_n,
            output [2:0]        tmds_data_p,


            // "Magic" port names that the gowin compiler connects to the on-chip SDRAM
            output		O_sdram_clk,
            output		O_sdram_cke,
            output		O_sdram_cs_n,   // chip select
            output		O_sdram_cas_n,  // columns address select
            output		O_sdram_ras_n,  // row address select
            output		O_sdram_wen_n,  // write enable
            inout [31:0]	IO_sdram_dq, // 32 bit bidirectional data bus
            output [10:0]	O_sdram_addr, // 11 bit multiplexed address bus
            output [1:0]	O_sdram_ba, // two banks
            output [3:0]	O_sdram_dqm, // 32/4

            output reg           spisdcard_clk,
            output reg           spisdcard_cs_n,
            input  wire          spisdcard_miso,
            output reg           spisdcard_mosi
    );

    wire [1:0] clkreg;
    wire clk, clk_hdmi_x5, clk_hdmi, clk60, clk48, clk24;
    wire [2:0] clk_available;


    wire clk_ready;

    clk_producer clk_producer_inst0 (
            .clk27(clk27),
            .clk50(clk50),

            .clk_hdmi_x5(clk_hdmi_x5),
            .clk_hdmi(clk_hdmi),

            .clk48(clk48),

            .clk60(clk60),

            .clk24(clk24),

            .clk_ready(clk_ready)
        );
    
    //assign clk = clk48;

    Gowin_DCS dcs0(
        .clkout(clk), //output clkout
        .clkreg(clkreg), //input [1:0] clkreg
        .clkin0(clk24), //input clkin0
        .clkin1(clk48), //input clkin1
        .clkin2(clk48), //input clkin2
        .clkin3(clk48) //input clkin3
    );




    wire reset_n; 

    reset_control reset_control_inst0 (
        .clk(clk),
        .reset_button_n(~btn0),
        .reset_n(reset_n)
    );


    wire reset;
    assign reset = ~reset_n;
    wire clk_div;

	divider #(.DIVIDER_NUMBER(6_750_000))divider_27 (
		.clk(clk27),
		.reset(reset),
		.clk_div(clk_div)
    );


    wire [7:0] leds_o;

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


   assign leds = ~leds_o[5:0]; // Connect to the LEDs off the FPGA
   //assign pmod0 = ~leds_o;

endmodule   // top_board
