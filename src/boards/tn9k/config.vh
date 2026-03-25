/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * File        : config.vh
 * Target : Gowin GW1NR-LV9 (Tang Nano 9K) 
 * Description : Global System-on-Chip (SoC) Configuration Header.
 * This file centralizes all hardware parameters, clocking geometry, and 
 * video timing profiles. By toggling the defines below, the entire system 
 * (CPU speed, RAM size, and HDMI resolution) is reconfigured at compile time.
 * ============================================================================
 * * MAIN SYSTEM FLAGS:
 * - SRAM_EXT_24K : When defined, enables extended 24KB addressing for Main RAM.
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

`define TN9K

`define SRAM_EXT_24K

`define HDMI_VIDEO_TEXT_80_32_50

`define LEDS_NB         6
`define BUTTONS_NB      0

`define CLK_AVAILABLE 2'b00 
// 00 12
// 01    + 48               // too high for tn9k
// 10         + 60
// 11 ...



`ifdef HDMI_VIDEO_TEXT_80_32_50
    
// timings for HDMI 1360x768 50Hz : 283.32 MHz
// 1440x787x50 = 56.664 => x5 = 283.32

// 1360x768 50Hz  
`define VIDEO_H_LENGTH          1440
`define VIDEO_H_VISIBLE         1360
`define VIDEO_H_SYNC_POL        1
`define VIDEO_H_SYNC_LEN        32
`define VIDEO_H_BP_LEN          40

`define VIDEO_V_LENGTH          787
`define VIDEO_V_VISIBLE         768
`define VIDEO_V_SYNC_POL        1
`define VIDEO_V_SYNC_LEN        8
`define VIDEO_V_BP_LEN          6

`define VIDEO_H_MARGE           40              
`define VIDEO_V_MARGE           0

`define SCREEN_DX               80
`define SCREEN_DY               32
`define SCREEN_REFRESH          50

`define H_CHAR_OFFSET           6

`else
    `error "Error: No HDMI configuration!"
`endif