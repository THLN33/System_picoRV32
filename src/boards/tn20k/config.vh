/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * File : config.vh
 * Target : Gowin GW2AR-LV18 (Tang Nano 20K) 
 * Description : Global System-on-Chip (SoC) Configuration Header.
 * This file centralizes all hardware parameters, clocking geometry, and 
 * video timing profiles. By toggling the defines below, the entire system 
 * (CPU speed, RAM size, and HDMI resolution) is reconfigured at compile time.
 * ============================================================================
 * * MAIN SYSTEM FLAGS:
 * - SRAM_EXT_64K : When defined, enables extended 64KB addressing for Main RAM.
 * - LEDS_NB      : Sets the bit-width for the GPIO LED output port.
 * - CLK_AVAILABLE: Hardware-specific indicator for input clock sources.
 *
 * This file supports multiple display profiles. The active profile determines:
 * 1. PLL DIVIDERS: Configures the VCO, Pixel Clock, Serial TMDS Clock, 
 * and CPU/Bus Clock (via MDIV and ODIV parameters).
 * 2. VIDEO TIMINGS: Sets horizontal and vertical sync, porches, and active 
 * resolution (compliant with VESA/CVT standards).
 * 3. TEXT GRID: Defines the SCREEN_DX/DY dimensions for the character engine
 * and applies margins to center the text buffer on the high-res frame.
 * ============================================================================
 */
`define CONFIG_V

`define TN20K           16'h0120

`define HDMI_VIDEO_TEXT_80_32_60

`define SRAM_EXT_64K

`define CLK_AVAILABLE 2'b01
// 00 24
// 01    + 48
// 10         + 60
// 11 ...

`define LEDS_NB         6
`define BUTTONS_NB      0

`ifdef HDMI_VIDEO_TEXT_80_32_60

    
// timings for HDMI 1366x768 60Hz : 425.25 MHz
`define HDMI_PLL_IDIV           3
`define HDMI_PLL_M              62
`define HDMI_PLL_N              2


// 1366x768 60Hz  ?CVT-RBv2
`define VIDEO_H_LENGTH          1782
`define VIDEO_H_VISIBLE         1366
`define VIDEO_H_SYNC_POL        1
`define VIDEO_H_SYNC_LEN        136
`define VIDEO_H_BP_LEN          192

`define VIDEO_V_LENGTH          798
`define VIDEO_V_VISIBLE         768
`define VIDEO_V_SYNC_POL        1
`define VIDEO_V_SYNC_LEN        10
`define VIDEO_V_BP_LEN          17

`define VIDEO_H_MARGE           40              
`define VIDEO_V_MARGE           0

`define SCREEN_DX               80
`define SCREEN_DY               32
`define SCREEN_REFRESH          60

`define H_CHAR_OFFSET           22

`else
    `error "Error: No HDMI configuration!"
`endif