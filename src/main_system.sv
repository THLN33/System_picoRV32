/*
 *  Copyright (C) 2026 THLN
 *
 * ============================================================================
 * Module      : main_system
 * Description : Top-Level System-on-Chip (SoC) for PicoRV32 RISC-V.
 * Integrates the CPU core, memory subsystems, and a suite of 
 * peripherals including UART, GPIO, Timers, and a Video Text Controller 
 * with HDMI/DVI output.
 *
 * Architecture:
 * - CPU: PicoRV32 with a native bus wrapper.
 * - Interconnect: Centralized bus switch routing requests to specific slaves.
 * - Video: Dual-port Video RAM text engine with TMDS/DVI transmission.
 * - Memory: Internal SRAM and External Memory interfaces.
 * ============================================================================
 * Clock Domains:
 * - clk          : Primary System/Bus Clock.
 * - clk24        : 24 MHz Reference for Timers and Video character blinking.
 * - clk_pixel    : HDMI Pixel Clock.
 * - clk_pixel_x5 : High-speed Serializer Clock for TMDS (DDR bit clock).
 * ============================================================================
 * Peripheral Mapping (Controlled via interconnect_inst0):
 * - Internal SRAM      : Primary program/data memory.
 * - External SRAM/DDR  : Extended memory space. (reserved, not yet supported)
 * - System Config      : Hardware ID and dynamic clock frequency control.
 * - Timer              : 32-bit counter with external 24MHz reference.
 * - UART               : Serial communication interface.
 * - Port I/O           : 8-bit GPIO (General Purpose Input/Output).
 * - Video Text RAM     : Memory-mapped character display engine.
 * ============================================================================
 */
import picorv32_bus_pkg::*; // Importation des types



module main_system (
        input wire          reset_n,

        input wire          clk,
        input wire          clk24,
        input wire          clk_pixel,
        input wire          clk_pixel_x5,

        output wire [1:0]   clkreg,

        input wire          uart_rx,
        output wire         uart_tx,

        output              tmds_clk_n,
        output              tmds_clk_p,
        output [2:0]        tmds_data_n,
        output [2:0]        tmds_data_p,

        input wire  [7:0]   port_in,
        output wire [7:0]   port_out,


        inout  wire  [15:0] ddram_dq,
        inout  wire   [1:0] ddram_dqs_n,
        inout  wire   [1:0] ddram_dqs_p,
        output wire  [13:0] ddram_a,
        output wire   [2:0] ddram_ba,
        output wire         ddram_cas_n,
        output wire         ddram_cke,
        output wire         ddram_clk_p,
        output wire         ddram_cs_n,
        output wire   [1:0] ddram_dm,
        output wire         ddram_odt,
        output wire         ddram_ras_n,
        output wire         ddram_reset_n,
        output wire         ddram_we_n,


        output reg          spisdcard_clk,
        output reg          spisdcard_cs_n,
        input  wire         spisdcard_miso,
        output reg          spisdcard_mosi
    );


    rv32_req_t  cpu_req;   // Contient addr, wdata, wstrb, select
    rv32_resp_t cpu_resp;  // Contient rdata, ready

    // Signaux de liaison individuels
    rv32_req_t  sram_req;    
    rv32_resp_t sram_resp;

    rv32_req_t  sram_ext_req;    
    rv32_resp_t sram_ext_resp;

    rv32_req_t  system_config_req;         
    rv32_resp_t system_config_resp;

    rv32_req_t  timer_req;         
    rv32_resp_t timer_resp;

    rv32_req_t  uart_req;        
    rv32_resp_t uart_resp;

    rv32_req_t  port_req;        
    rv32_resp_t port_resp;

    rv32_req_t  video_ram_req;   
    rv32_resp_t video_ram_resp;


    picorv32_wrapper picorv32_wrapper_inst0 (
        .clk(clk),
        .reset_n(reset_n),

        .req_out(cpu_req),
        .resp_in(cpu_resp)
    );


    bus_interconnect interconnect_inst0 (
        //.clk,

        .cpu_req(cpu_req),   
        .cpu_resp(cpu_resp), // Vers le CPU
        
        .sram_req(sram_req), 
        .sram_resp(sram_resp),

        .sram_ext_req(sram_ext_req), 
        .sram_ext_resp(sram_ext_resp),

        .system_config_req(system_config_req),           
        .system_config_resp(system_config_resp),

        .timer_req(timer_req),           
        .timer_resp(timer_resp),

        .uart_req(uart_req),         
        .uart_resp(uart_resp),

        .port_req(port_req),         
        .port_resp(port_resp),

        .ram_video_req(video_ram_req), 
        .ram_video_resp(video_ram_resp)

    );

    sram sram_inst0 (
        .clk(clk),
        .resetn(reset_n),

        .req(sram_req),
        .resp(sram_resp)
    );

    //wire    sram_ext_reset_n = 1;

    sram_ext sram_ext_inst0 (
        .clk(clk),
        .resetn(1'b1),

        .req(sram_ext_req),
        .resp(sram_ext_resp)
    );




    system_config  #(
        .init_word_ident0({8'b0, (`SCREEN_REFRESH*256*256) + (`SCREEN_DY*256) + `SCREEN_DX}),
        .init_word_ident1({8'b0, (`BUTTONS_NB*256*256) + (`LEDS_NB*256) + `CLK_AVAILABLE})
    ) system_config_inst0 (
        .clk(clk),
        .reset_n(reset_n),

        .req(system_config_req),           
        .resp(system_config_resp),

        .word_ident0(word_ident0),
        .word_ident1(word_ident1),

        .clkreg(clkreg)
    );


    timer timer_inst0 (
        .reset_n(reset_n),

        .clk(clk),
        .timer_clk(clk24),

        .req(timer_req),
        .resp(timer_resp),

        .irq()
    );

    uart_wrap uart_wrap_inst0 (
        .clk(clk),
        .reset_n(reset_n),

        .req(uart_req),
        .resp(uart_resp),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx)        
    );


    port_inout port_inout_inst0 (
        .clk(clk),
        .reset_n(reset_n),

        .req(port_req),
        .resp(port_resp),

        .port_in(port_in),
        .port_out(port_out)
    );



    /* HDMI */

    wire reset;
    assign reset = 0;

    wire [23:0]	        dvi_data;
    wire				dvi_den;
    wire				dvi_hsync;
    wire				dvi_vsync;



    video_text video_text_inst0 (
        .reset				(reset),

        .clk24              (clk24),        
        .bus_clk            (clk),

        .req(video_ram_req),
        .resp(video_ram_resp),

		.pixel_clock		(clk_pixel),
				
		.video_vsync		(dvi_vsync),
		.video_hsync		(dvi_hsync),
		.video_den			(dvi_den),
        .video_line_start   (),
		.video_pixel	    (dvi_data)

    );

	dvi_tx_top dvi_tx_top_inst0(
		
		.pixel_clock		(clk_pixel),
		.ddr_bit_clock		(clk_pixel_x5),
		.reset				(reset),
		
		.den				(dvi_den),
		.hsync				(dvi_hsync),
		.vsync				(dvi_vsync),
		.pixel_data			(dvi_data),
		
		.tmds_clk			({tmds_clk_p, tmds_clk_n}),
		.tmds_d0			({tmds_data_p[0], tmds_data_n[0]}),
		.tmds_d1			({tmds_data_p[1], tmds_data_n[1]}),
		.tmds_d2			({tmds_data_p[2], tmds_data_n[2]})
	);


endmodule


