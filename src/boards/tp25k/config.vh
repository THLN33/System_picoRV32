/*
 * Copyright (C) 2026 THLN
 *
 * ============================================================================
 * File : config.vh
 * Target : Gowin GW5A-LV25 (Tang Primer 25K) 
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

`define SRAM_EXT_64K

`define LEDS_NB         8
`define BUTTONS_NB      0

//`define HDMI_VIDEO_TEXT_80_32_60
`define HDMI_VIDEO_TEXT_96_42_60


`define CLK_AVAILABLE 2'b10
// 00 12
// 01    + 48
// 10         + 60
// 11 ...


`ifdef HDMI_VIDEO_TEXT_96_42_60
/*
 * ============================================================================
 * 1. 96x42 Configuration (High Resolution)
 * This configuration targets a resolution of 1680x1050 (WSXGA+).
 * Compatibility: Uses CVT-RB (Reduced Blanking) to minimize bandwidth.
 *
 * VCO (Internal PLL Frequency): 50 MHz × 24 (MDIV) = 1200 MHz
 * System/CPU       (ODIV0): 1200 MHz / 20 =   60 MHz
 * HDMI Bit Clock   (ODIV1): 1200 MHz / 2   = 600 MHz
 * Pixel Clock      (ODIV2): 1200 MHz / 10  = 120 MHz  
 * ----------------------------------------------------------------------------
 */
`define PLLA_ODIV0_SEL          20           // div20    = 60MHz
`define PLLA_ODIV1_SEL          2            // div2     = 600MHz
`define PLLA_ODIV2_SEL          10           // div10    = 120MHz 
`define PLLA_MDIV_SEL           24           // 24*50 = 1200MHz 

// 1680x1050 60Hz
`define VIDEO_H_LENGTH          1840
`define VIDEO_H_VISIBLE         1680
`define VIDEO_H_SYNC_POL        1
`define VIDEO_H_SYNC_LEN        32
`define VIDEO_H_BP_LEN          80

`define VIDEO_V_LENGTH          1080
`define VIDEO_V_VISIBLE         1050
`define VIDEO_V_SYNC_POL        1
`define VIDEO_V_SYNC_LEN        6
`define VIDEO_V_BP_LEN          21

`define VIDEO_H_MARGE           72              
`define VIDEO_V_MARGE           21

`define SCREEN_DX               96
`define SCREEN_DY               42
`define SCREEN_REFRESH          60

`define H_CHAR_OFFSET           10

`else

`ifdef HDMI_VIDEO_TEXT_80_32_60
/*
 * ============================================================================
 * 2. 80x32 Configuration (Standard Resolution)
 * This configuration targets a resolution of 1366x768 (HD Ready).
 *
 * VCO (Internal PLL Frequency): 50 MHz × 17 (MDIV) = 850 MHz
 * System/CPU       (ODIV0): 850 MHz / 14  ≈ 60.7 MHz
 * HDMI Bit Clock   (ODIV1): 850 MHz / 2   = 425 MHz
 * Pixel Clock      (ODIV2): 850 MHz / 10  = 85 MHz
 * ============================================================================
 */
 
`define PLLA_ODIV0_SEL          14           // div14    = 60.7MHz 
`define PLLA_ODIV1_SEL          2            // div2     = 425MHz 
`define PLLA_ODIV2_SEL          10           // div10    = 85MHz 
`define PLLA_MDIV_SEL           17           // 17*50    = 850MHz 

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
`endif

